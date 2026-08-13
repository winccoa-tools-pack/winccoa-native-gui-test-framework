# Squirt - WinCC OA GUI test framework

is a framework to test WinCC OA native panels (GUI) provided in the .pnl or .xml format.

----
## Usage

+ provide tests by macro recording
+ provide verification points by macro recording
+ replay and execute tests
+ logs all verification points (asserts)
+ create screenshots on assertions
+ bind tests into WinCC OA test frameworks
+ ...

----
## Configuration

TBD

----
## Examples

TBD

----
## Contributing

### Code Style

TBD

### Code coverage

TBD

----
## License

TBD

## Limitation

Only WinCC OA shapes are possible to record / re-play. That means no file-selector, printers ... can be recorded.

## Do not ...

+ Do not use **:** in the panel name, otherwise it is not possible to address the shape (moduleName.panelName:shapeName).
+ Do not use empty shape name, otherwise it is not possible to address the shape (moduleName.panelName:shapeName).
+ Use unique shape name, otherwise you will have conflict in the Tab shape
+ Do not use random generated module, shape and panel names, otherwise the player can not address the shape.

## Best practice

+ Create smaller test cases instead of complex long duration tests. It will help you for analysis and you does not need
  to record whole scenario, when something changes
