module ElmCompiler exposing (OutputType(..), Options, compileToString)

import Json.Encode as Json
import Task exposing (Task)
import FFI


type OutputType
    = Html
    | Js


type alias Options =
    { output : Maybe OutputType
    }


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
