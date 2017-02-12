# elm-node-elm-compiler
Elm compiler via node-elm-compiler

## Install

You need [elm-proper-install](https://github.com/eeue56/elm-proper-install) in order to install this package.

```
elm-proper-install eeue56/elm-node-elm-compiler
```

## Usage


You may want to compile an Elm file to a string you can check out. This is an example of compiling `example/Main.elm` to Html.

```elm
Task.attempt CompiledThing (compileToString ({ output = Just ElmCompiler.Html }) "example/Main.elm"
```

You may want to just compile an Elm file, and don't care about getting the result. You can do that with something like the below, which will store the generated file in `_test.js`.

```elm
Task.attempt CompileToFile (compileToFile "example/Main.elm" "_test.js")
```
