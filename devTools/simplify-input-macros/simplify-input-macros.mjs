#!/usr/bin/env node

import { readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

export const MAX_CLICK_HOLD_MS = 100;
export const LONG_SLEEP_WARNING_MS = 10_000;

const pressPattern = /^([\t ]*)player\.mouseEvent\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(MOUSE_LEFT|MOUSE_RIGHT)\s*,\s*(.*?)\s*\);\s*$/;
const releasePattern = /^\s*player\.mouseEvent\(\s*(\d+)\s*,\s*(\d+)\s*,\s*0\s*,\s*(.*?)\s*\);\s*$/;
const sleepPattern = /^\s*player\.sleep\(\s*(\d+)\s*\);\s*$/;
const commentPattern = /^\s*\/\/\s*(\S.*)$/;
const makeCurrentPattern = /^\s*player\.makeCurrent\(\s*"([^"]+)"\s*\);\s*$/;
const keyClickPattern = /^\s*player\.keyClick\(\s*("(?:[^"\\]|\\.)*")\s*,\s*([^,]+?)\s*,\s*([^)]+?)\s*\);\s*$/;
const mouseEventPattern = /^\s*player\.mouseEvent\(\s*(\d+)\s*,\s*(\d+)\s*,\s*([^,]+?)\s*,\s*(.*?)\s*\);\s*$/;

function splitLines(source) {
  const lines = [];
  let offset = 0;

  while (offset < source.length) {
    const start = offset;

    while (offset < source.length &&
           source[offset] !== "\r" && source[offset] !== "\n")
      offset++;

    if (offset < source.length) {
      if (source[offset] === "\r" && source[offset + 1] === "\n")
        offset += 2;
      else
        offset++;
    }

    lines.push(source.slice(start, offset));
  }

  return lines;
}

function lineBody(line) {
  return line.replace(/(?:\r\n|\n|\r)$/, "");
}

function lineEnding(line) {
  return /(?:\r\n|\n|\r)$/.exec(line)?.[0] ?? "";
}

function parseKeyClick(line) {
  const match = keyClickPattern.exec(lineBody(line));

  if (!match)
    return null;

  return {
    textLiteral: match[1],
    key: match[2].trim().toUpperCase(),
    modifiers: match[3].trim().toUpperCase(),
  };
}

function isClearTextStart(event) {
  return event.textLiteral === '""' &&
         ["0X41", "65", "KEY_A"].includes(event.key) &&
         event.modifiers === "KEY_CONTROL";
}

function isBackspace(event) {
  return event.textLiteral === '""' &&
         ["0X01000003", "16777219", "KEY_BACKSPACE"].includes(event.key) &&
         ["0", "0X0"].includes(event.modifiers);
}

function isTextInput(event) {
  return event.textLiteral !== '""' &&
         ["0", "0X0"].includes(event.key) &&
         ["0", "0X0"].includes(event.modifiers);
}

function analyzeKeyClicks(lines) {
  const recommendations = [];
  let shapeAddress = "";

  for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    const body = lineBody(lines[lineIndex]);

    if (/^\s*}\s*$/.test(body) || /^\s*(?:int|void)\s+\w+\s*\(/.test(body))
      shapeAddress = "";

    const currentShape = makeCurrentPattern.exec(body);

    if (currentShape) {
      shapeAddress = currentShape[1];
      continue;
    }

    const event = parseKeyClick(lines[lineIndex]);

    if (!event)
      continue;

    if (isClearTextStart(event) && lineIndex + 1 < lines.length) {
      const nextEvent = parseKeyClick(lines[lineIndex + 1]);

      if (nextEvent && isBackspace(nextEvent)) {
        recommendations.push({
          type: "clearText",
          line: lineIndex + 1,
          endLine: lineIndex + 2,
          shapeAddress,
          replacement: shapeAddress ?
                       `player.clearText("${shapeAddress}");` : "",
        });
        lineIndex++;
        continue;
      }
    }

    if (!isTextInput(event))
      continue;

    const textLiterals = [event.textLiteral];
    let endIndex = lineIndex;

    while (endIndex + 1 < lines.length) {
      const nextEvent = parseKeyClick(lines[endIndex + 1]);

      if (!nextEvent || !isTextInput(nextEvent))
        break;

      textLiterals.push(nextEvent.textLiteral);
      endIndex++;
    }

    if (textLiterals.length > 1) {
      recommendations.push({
        type: "writeText",
        line: lineIndex + 1,
        endLine: endIndex + 1,
        shapeAddress,
        replacement: shapeAddress ?
                     `player.writeText("${shapeAddress}", ` +
                     `${textLiterals.join(" + ")});` : "",
      });
      lineIndex = endIndex;
    }
  }

  return addManualKeyReview(lines, recommendations);
}

function addManualKeyReview(lines, recommendations) {
  let shapeAddress = "";
  let events = [];

  function flushEvents() {
    if (events.length < 2) {
      events = [];
      return;
    }

    const firstLine = events[0].line;
    const lastLine = events[events.length - 1].line;
    const hasSpecificRecommendation = recommendations.some(
      (recommendation) => recommendation.line <= firstLine &&
                          recommendation.endLine >= lastLine);

    if (!hasSpecificRecommendation) {
      recommendations.push({
        type: "manualReview",
        line: firstLine,
        endLine: lastLine,
        shapeAddress,
        keyClickCount: events.length,
        replacement: "",
      });
    }

    events = [];
  }

  for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    const body = lineBody(lines[lineIndex]);

    if (/^\s*}\s*$/.test(body) || /^\s*(?:int|void)\s+\w+\s*\(/.test(body)) {
      flushEvents();
      shapeAddress = "";
      continue;
    }

    const currentShape = makeCurrentPattern.exec(body);

    if (currentShape) {
      flushEvents();
      shapeAddress = currentShape[1];
      continue;
    }

    if (parseKeyClick(lines[lineIndex])) {
      events.push({ line: lineIndex + 1 });
      continue;
    }

    const sleep = sleepPattern.exec(body);

    if (sleep && events.length > 0 && Number(sleep[1]) <= 1000)
      continue;

    if (body.trim() === "" && events.length > 0)
      continue;

    flushEvents();
  }

  flushEvents();
  return recommendations.sort((left, right) => left.line - right.line);
}

function analyzeMouseMovements(lines) {
  const findings = [];
  let shapeAddress = "";
  let buttonHeld = false;
  let previousMove;

  for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    const body = lineBody(lines[lineIndex]);

    if (/^\s*}\s*$/.test(body) || /^\s*(?:int|void)\s+\w+\s*\(/.test(body)) {
      shapeAddress = "";
      buttonHeld = false;
      previousMove = undefined;
      continue;
    }

    const currentShape = makeCurrentPattern.exec(body);

    if (currentShape) {
      shapeAddress = currentShape[1];
      buttonHeld = false;
      previousMove = undefined;
      continue;
    }

    const event = mouseEventPattern.exec(body);

    if (event) {
      const current = {
        line: lineIndex + 1,
        x: Number(event[1]),
        y: Number(event[2]),
        modifiers: event[4].trim(),
      };

      if (event[3].trim() !== "0") {
        buttonHeld = true;
        previousMove = undefined;
        continue;
      }

      if (buttonHeld) {
        buttonHeld = false;
        previousMove = undefined;
        continue;
      }

      if (previousMove && previousMove.line === current.line - 1) {
        const duplicate = previousMove.x === current.x &&
                          previousMove.y === current.y &&
                          previousMove.modifiers === current.modifiers;

        findings.push({
          type: duplicate ? "duplicateMove" : "supersededMove",
          line: previousMove.line,
          endLine: current.line,
          shapeAddress,
          fromX: previousMove.x,
          fromY: previousMove.y,
          toX: current.x,
          toY: current.y,
        });
      }

      previousMove = current;
      continue;
    }

    previousMove = undefined;
  }

  return findings;
}

export function simplifyText(source) {
  const lines = splitLines(source);
  const output = [];
  const candidates = [];
  const longSleeps = [];
  const keyRecommendations = analyzeKeyClicks(lines);
  const mouseMovementFindings = analyzeMouseMovements(lines);

  for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    const sleep = sleepPattern.exec(lineBody(lines[lineIndex]));

    if (!sleep)
      continue;

    const durationMs = Number(sleep[1]);

    if (durationMs <= LONG_SLEEP_WARNING_MS)
      continue;

    const previousLine = lineIndex > 0 ? lineBody(lines[lineIndex - 1]) : "";
    const comment = commentPattern.exec(previousLine);
    longSleeps.push({
      line: lineIndex + 1,
      durationMs,
      reasonComment: comment ? comment[1].trim() : "",
    });
  }

  for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    const press = pressPattern.exec(lineBody(lines[lineIndex]));

    if (!press) {
      output.push(lines[lineIndex]);
      continue;
    }

    let releaseIndex = lineIndex + 1;
    let holdMs = 0;

    if (releaseIndex < lines.length) {
      const sleep = sleepPattern.exec(lineBody(lines[releaseIndex]));

      if (sleep) {
        holdMs = Number(sleep[1]);
        releaseIndex++;
      }
    }

    if (holdMs > MAX_CLICK_HOLD_MS || releaseIndex >= lines.length) {
      output.push(lines[lineIndex]);
      continue;
    }

    const release = releasePattern.exec(lineBody(lines[releaseIndex]));
    const xCoordinate = press[2];
    const yCoordinate = press[3];
    const modifiers = press[5].trim();

    if (!release || release[1] !== xCoordinate ||
      release[2] !== yCoordinate ||
        release[3].trim() !== modifiers) {
      output.push(lines[lineIndex]);
      continue;
    }

    const method = press[4] === "MOUSE_LEFT" ?
                   "leftMouseClick" : "rightMouseClick";
    const replacement = `${press[1]}player.${method}(${xCoordinate}, ` +
              `${yCoordinate}, ${modifiers});`;
    const ending = lineEnding(lines[releaseIndex]) ||
                   lineEnding(lines[lineIndex]);

    output.push(replacement + ending);
    candidates.push({
      line: lineIndex + 1,
      endLine: releaseIndex + 1,
      button: press[4],
      x: Number(xCoordinate),
      y: Number(yCoordinate),
      modifiers,
      holdMs,
      replacement,
    });
    lineIndex = releaseIndex;
  }

  return {
    output: output.join(""),
    candidates,
    longSleeps,
    keyRecommendations,
    mouseMovementFindings,
  };
}

function printUsage() {
  console.log(`Usage: node simplify-input-macros.mjs [--dry-run | --apply] <file.ctl ...>

Dry-run is the default. It reports recognized click sequences without editing.
Long sleeps are reported and require a rationale comment directly above them.
Key-click runs are reported as advisory writeText/clearText suggestions.
Consecutive button-free pointer events are reported as possible redundant moves.
--apply writes the proposed simplifications back to the input files.`);
}

async function main(args) {
  let mode;
  const paths = [];

  for (const arg of args) {
    if (arg === "--help" || arg === "-h") {
      printUsage();
      return;
    }

    if (arg === "--dry-run" || arg === "--apply") {
      const requestedMode = arg === "--apply" ? "apply" : "dry-run";

      if (mode && mode !== requestedMode)
        throw new Error("Choose either --dry-run or --apply, not both.");

      mode = requestedMode;
      continue;
    }

    paths.push(arg);
  }

  if (paths.length === 0) {
    printUsage();
    process.exitCode = 2;
    return;
  }

  mode ??= "dry-run";

  for (const path of paths) {
    try {
      const source = await readFile(path, "utf8");
      const result = simplifyText(source);

      console.log(`${path}: ${result.candidates.length} click candidate(s), ` +
          `${result.keyRecommendations.length} key sequence finding(s)`);

      for (const candidate of result.candidates) {
        console.log(`  lines ${candidate.line}-${candidate.endLine}: ` +
                    `${candidate.button} at (${candidate.x}, ${candidate.y}), ` +
                    `recorded hold ${candidate.holdMs}ms`);
        console.log(`    -> ${candidate.replacement}`);
      }

      for (const longSleep of result.longSleeps) {
        const rationale = longSleep.reasonComment || "missing rationale comment";
        console.log(`  line ${longSleep.line}: long sleep ` +
                    `${longSleep.durationMs}ms; ${rationale}`);
      }

      for (const recommendation of result.keyRecommendations) {
        const address = recommendation.shapeAddress ||
                        "no preceding player.makeCurrent address";

        if (recommendation.type === "manualReview") {
          console.log(`  lines ${recommendation.line}-${recommendation.endLine}: ` +
                      `${recommendation.keyClickCount} keyClick calls need ` +
                      `manual review at ${address}`);
          continue;
        }

        console.log(`  lines ${recommendation.line}-${recommendation.endLine}: ` +
                    `${recommendation.type} candidate for ${address}`);
        console.log(recommendation.replacement ?
                    `    -> ${recommendation.replacement}` :
                    "    -> resolve the target shape before replacing");
      }

      for (const finding of result.mouseMovementFindings) {
        const description = finding.type === "duplicateMove" ?
                            "repeats the same pointer position" :
                            "is immediately superseded by another pointer position";
        const address = finding.shapeAddress || "unknown shape";
        console.log(`  lines ${finding.line}-${finding.endLine}: possible ` +
                    `redundant mouse movement on ${address}: ${description} ` +
                    `(${finding.fromX}, ${finding.fromY}) -> ` +
                    `(${finding.toX}, ${finding.toY}); review manually`);
      }

      const missingRationale = result.longSleeps.filter(
        (longSleep) => !longSleep.reasonComment);

      if (mode === "apply" && missingRationale.length > 0) {
        const lines = missingRationale.map((longSleep) => longSleep.line);
        console.error("  not applied: add a comment explaining each long " +
                      `sleep at line(s) ${lines.join(", ")}.`);
        process.exitCode = 1;
        continue;
      }

      if (mode === "apply" && result.output !== source) {
        await writeFile(path, result.output, "utf8");
        console.log("  applied");
      }
    } catch (error) {
      console.error(`${path}: ${error.message}`);
      process.exitCode = 1;
    }
  }
}

if (process.argv[1] &&
    import.meta.url === pathToFileURL(resolve(process.argv[1])).href)
  await main(process.argv.slice(2));