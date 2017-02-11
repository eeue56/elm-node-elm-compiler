module ElmCompiler exposing (OutputType(..), Options, compileToString, compileToFile)

{-|

This module is intended to be used to wrap around node-elm-compiler.

@docs compileToString, compileToFile

@docs OutputType, Options

-}

import Json.Encode as Json
import Task exposing (Task)
import FFI


{-| Html for Html output, Js for Js
-}
type OutputType
    = Html
    | Js


{-| You don't need to provide output type but it's recommended
-}
type alias Options =
    { output : Maybe OutputType
    }


{-| Compile a given Elm filename into either a html string or a Js string

    >>> compileToString { output = Just Html } "example/Main.elm" |> String.contains "<html>"
    True

    >>> compileToString { output = Just Js } "example/Main.elm" |> String.contains "<html>"
    False
-}
compileToString : Options -> String -> Task String String
compileToString options filename =
    FFI.async """
var compileToString = require('node-elm-compiler').compileToString;
compileToString(_0, _1).then(function(body){
    callback(_succeed(body));
}).catch(function(error){
    callback(_fail(error.message));
});
    """ [ Json.string filename, optionsToJson options ]
        |> Task.map FFI.intoElm
        |> Task.mapError FFI.intoElm


{-| Compile a given Elm filename into a file. Does not tell you if it fails!

    >>> compileToFile "example/Main.elm" Nothing

    >>> compileToFile "example/Main.elm" (Just "elm.js")
-}
compileToFile : String -> String -> Task String ()
compileToFile filename outputFilename =
    FFI.async """
process.on('exit', function() {
    callback(_fail("Failed to process file: " + _1));
});
var compile = require('node-elm-compiler').compile;
compile(_0, _1);
return callback(_succeed(_2));
    """ [ Json.string filename, Json.object [ ( "output", Json.string outputFilename ) ], FFI.asIs () ]
        |> Task.map (\_ -> ())
        |> Task.mapError FFI.intoElm


outputToJson : OutputType -> Json.Value
outputToJson =
    toString
        >> String.toLower
        >> (\x -> "." ++ x)
        >> Json.string


optionsToJson : Options -> Json.Value
optionsToJson options =
    case options.output of
        Nothing ->
            Json.object []

        Just outputType ->
            Json.object [ ( "output", outputToJson outputType ) ]
