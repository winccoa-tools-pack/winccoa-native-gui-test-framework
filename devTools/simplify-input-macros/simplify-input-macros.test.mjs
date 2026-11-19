import assert from "node:assert/strict";
import test from "node:test";

import { simplifyText } from "./simplify-input-macros.mjs";

test("reports and simplifies a matching left-click sequence", () => {
  const source = [
    "  player.mouseEvent(12, 12, MOUSE_LEFT, 0);",
    "  player.sleep(53);",
    "  player.mouseEvent(12, 12, 0, 0);",
    "",
  ].join("\r\n");

  const result = simplifyText(source);

  assert.equal(result.candidates.length, 1);
  assert.equal(result.candidates[0].line, 1);
  assert.equal(result.candidates[0].endLine, 3);
  assert.equal(result.candidates[0].holdMs, 53);
  assert.equal(result.output, "  player.leftMouseClick(12, 12, 0);\r\n");
});

test("simplifies a matching right-click without an explicit wait", () => {
  const source = [
    "player.mouseEvent(8, 9, MOUSE_RIGHT, KEY_CONTROL);",
    "player.mouseEvent(8, 9, 0, KEY_CONTROL);",
  ].join("\n");

  const result = simplifyText(source);

  assert.equal(result.candidates.length, 1);
  assert.equal(result.candidates[0].holdMs, 0);
  assert.equal(result.output,
               "player.rightMouseClick(8, 9, KEY_CONTROL);\n");
});

test("leaves mismatched and long-hold sequences unchanged", () => {
  const source = [
    "player.mouseEvent(12, 12, MOUSE_LEFT, 0);",
    "player.sleep(53);",
    "player.mouseEvent(13, 12, 0, 0);",
    "player.mouseEvent(12, 12, MOUSE_LEFT, 0);",
    "player.sleep(101);",
    "player.mouseEvent(12, 12, 0, 0);",
  ].join("\n");

  const result = simplifyText(source);

  assert.equal(result.candidates.length, 0);
  assert.equal(result.output, source);
});

test("leaves press-release modifier mismatches unchanged", () => {
  const source = [
    "player.mouseEvent(12, 12, MOUSE_LEFT, KEY_CONTROL);",
    "player.sleep(53);",
    "player.mouseEvent(12, 12, 0, 0);",
  ].join("\n");

  const result = simplifyText(source);

  assert.equal(result.candidates.length, 0);
  assert.equal(result.output, source);
});

test("reports long sleeps and their immediate rationale comments", () => {
  const source = [
    "void macro(InputEventPlayer &player)",
    "{",
    "  player.sleep(15000);",
    "  // Wait for the datapoint selector to finish loading.",
    "  player.sleep(30000);",
    "}",
  ].join("\n");

  const result = simplifyText(source);

  assert.deepEqual(result.longSleeps, [
    { line: 3, durationMs: 15000, reasonComment: "" },
    {
      line: 5,
      durationMs: 30000,
      reasonComment: "Wait for the datapoint selector to finish loading.",
    },
  ]);
  assert.equal(result.output, source);
});

test("does not report sleeps at the warning threshold", () => {
  const result = simplifyText("player.sleep(10000);\n");

  assert.deepEqual(result.longSleeps, []);
});

test("recommends clearText for select-all followed by Backspace", () => {
  const source = [
    'player.makeCurrent("Vision_1.panel:input");',
    "player.keyClick(\"\", 0x41, KEY_CONTROL);",
    "player.keyClick(\"\", 0x01000003, 0);",
  ].join("\n");

  const result = simplifyText(source);

  assert.deepEqual(result.keyRecommendations, [{
    type: "clearText",
    line: 2,
    endLine: 3,
    shapeAddress: "Vision_1.panel:input",
    replacement: 'player.clearText("Vision_1.panel:input");',
  }]);
  assert.equal(result.output, source);
});

test("recommends writeText for adjacent literal text key events", () => {
  const source = [
    'player.makeCurrent("Vision_1.panel:input");',
    'player.keyClick("alpha", 0, 0);',
    'player.keyClick("beta", 0, 0);',
  ].join("\n");

  const result = simplifyText(source);

  assert.deepEqual(result.keyRecommendations, [{
    type: "writeText",
    line: 2,
    endLine: 3,
    shapeAddress: "Vision_1.panel:input",
    replacement: 'player.writeText("Vision_1.panel:input", "alpha" + "beta");',
  }]);
  assert.equal(result.output, source);
});

test("does not recommend text helpers without a known shape address", () => {
  const source = [
    'player.keyClick("alpha", 0, 0);',
    'player.keyClick("beta", 0, 0);',
  ].join("\n");

  const result = simplifyText(source);

  assert.equal(result.keyRecommendations.length, 1);
  assert.equal(result.keyRecommendations[0].replacement, "");
});

test("reports unsupported multi-key sequences for manual review", () => {
  const source = [
    'player.makeCurrent("Vision_1.dpSelector:txtDpFilter");',
    'player.keyClick("\\x16", 86, KEY_CONTROL);',
    "player.sleep(516);",
    'player.keyClick("", KEY_RETURN, 0);',
  ].join("\n");

  const result = simplifyText(source);

  assert.deepEqual(result.keyRecommendations, [{
    type: "manualReview",
    line: 2,
    endLine: 4,
    shapeAddress: "Vision_1.dpSelector:txtDpFilter",
    keyClickCount: 2,
    replacement: "",
  }]);
});

test("does not duplicate specific helper recommendations as manual review", () => {
  const source = [
    'player.makeCurrent("Vision_1.panel:input");',
    'player.keyClick("", 0x41, KEY_CONTROL);',
    'player.keyClick("", 0x01000003, 0);',
  ].join("\n");

  const result = simplifyText(source);

  assert.equal(result.keyRecommendations.length, 1);
  assert.equal(result.keyRecommendations[0].type, "clearText");
});

test("reports adjacent unpressed pointer moves for manual review", () => {
  const source = [
    'player.makeCurrent("Vision_1.panel:area");',
    "player.mouseEvent(20, 30, 0, 0);",
    "player.mouseEvent(40, 50, 0, 0);",
    "player.mouseEvent(40, 50, 0, 0);",
  ].join("\n");

  const result = simplifyText(source);

  assert.deepEqual(result.mouseMovementFindings, [
    {
      type: "supersededMove",
      line: 2,
      endLine: 3,
      shapeAddress: "Vision_1.panel:area",
      fromX: 20,
      fromY: 30,
      toX: 40,
      toY: 50,
    },
    {
      type: "duplicateMove",
      line: 3,
      endLine: 4,
      shapeAddress: "Vision_1.panel:area",
      fromX: 40,
      fromY: 50,
      toX: 40,
      toY: 50,
    },
  ]);
  assert.equal(result.output, source);
});

test("does not flag mouse button releases or moves separated by actions", () => {
  const source = [
    "player.mouseEvent(20, 30, MOUSE_LEFT, 0);",
    "player.sleep(50);",
    "player.mouseEvent(20, 30, 0, 0);",
    "player.mouseEvent(40, 50, 0, 0);",
    "player.sleep(50);",
    "player.mouseEvent(60, 70, 0, 0);",
  ].join("\n");

  const result = simplifyText(source);

  assert.deepEqual(result.mouseMovementFindings, []);
});