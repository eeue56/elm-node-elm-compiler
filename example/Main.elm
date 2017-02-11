module Main exposing (..)

import Task
import Platform
import ElmCompiler exposing (compileToString, compileToFile)


main : Program Never Model Msg
main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    Int


init : ( Model, Cmd Msg )
init =
    ( 0
    , Cmd.batch
        [ Task.attempt CompiledThing (compileToString ({ output = Just ElmCompiler.Html }) "example/Main.elm")
        , Task.attempt CompileToFile (compileToFile "example/Main.elm" "_test.js")
        ]
    )


type Msg
    = CompiledThing (Result String String)
    | CompileToFile (Result String ())


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        CompiledThing thing ->
            case thing of
                Err message ->
                    let
                        _ =
                            Debug.log "Urm, it failed due to " message
                    in
                        ( model, Cmd.none )

                Ok answer ->
                    let
                        _ =
                            Debug.log "It passed! And was " <| String.length answer
                    in
                        ( model, Cmd.none )

        CompileToFile thing ->
            case thing of
                Err message ->
                    let
                        _ =
                            Debug.log "Compile to file failed due to " message
                    in
                        ( model, Cmd.none )

                Ok answer ->
                    let
                        _ =
                            Debug.log "compile to file passed!" ""
                    in
                        ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
