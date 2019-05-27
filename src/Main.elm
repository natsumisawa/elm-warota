port module Main exposing (Model, Msg(..), init, main, update, validatePhrase, view, viewEyeImg, viewFaceImg, viewMouthImg)

import Browser
import Html exposing (Attribute, Html, a, button, canvas, div, h1, h3, img, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Random
import Task
import Time


port toImg : List String -> Cmd msg


port resetImg : String -> Cmd msg



---- MODEL ----


type alias Model =
    { phrase : String
    , face : Int
    , color : Int
    , eye : Int
    , mouth : Int
    , isCreatedImg : Bool
    , poused : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { phrase = "", face = 1, color = 1, eye = 1, mouth = 1, isCreatedImg = False, poused = False }, Cmd.none )



---- UPDATE ----


type Msg
    = Phrase String
    | ChangeFace
    | ChangeColor
    | ChangeEye
    | ChangeMouth
    | ToImg
    | Reset
    | Random
    | NewFace Int
    | NewColor Int
    | NewEye Int
    | NewMouth Int
    | Move
    | MoveEveryOneSec Time.Posix
    | Stop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Phrase input ->
            ( { model | phrase = input }, Cmd.none )

        ChangeFace ->
            ( { model | face = model.face + 1 }, Cmd.none )

        ChangeColor ->
            ( { model | color = model.color + 1 }, Cmd.none )

        ChangeEye ->
            ( { model | eye = model.eye + 1 }, Cmd.none )

        ChangeMouth ->
            ( { model | mouth = model.mouth + 1 }, Cmd.none )

        ToImg ->
            ( { model | isCreatedImg = True }, toImg [ model.phrase, getFaceNum model.face, String.fromInt <| modBy 2 model.color, String.fromInt <| modBy 3 model.mouth ] )

        Reset ->
            ( { model | isCreatedImg = False }, resetImg "リセット" )

        Random ->
            ( { model | isCreatedImg = False }, Random.generate NewFace (Random.int 1 10) )

        NewFace new ->
            ( { model | face = modBy 2 new }, Random.generate NewEye (Random.int 1 10) )

        NewEye new ->
            ( { model | eye = modBy 5 new }, Random.generate NewColor (Random.int 1 30) )

        NewColor new ->
            ( { model | color = modBy 2 new }, Random.generate NewMouth (Random.int 1 10) )

        NewMouth new ->
            ( { model | mouth = modBy 3 new }, Cmd.none )

        Move ->
            ( { model | poused = False }, Cmd.none )

        MoveEveryOneSec time ->
            ( model, Random.generate NewFace (Random.int 1 10) )

        Stop ->
            ( { model | poused = True }, Cmd.none )



-- TODO random map?か関数合成


getFaceNum : Int -> String
getFaceNum face =
    if modBy 2 face == 0 then
        "warota"

    else
        "a-ne"



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.poused then
        Sub.none

    else
        Time.every 100 MoveEveryOneSec



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ div [ class "header" ]
            [ h1 []
                [ text "ワロタジェネレーター" ]
            , div [ class "change-button" ]
                [ a
                    [ onClick ChangeFace ]
                    [ img [ class "change", src "../public/warota-face.JPEG" ] [] ]
                , a
                    [ onClick ChangeColor ]
                    [ img [ class "change", src "../public/color-button.JPEG" ] [] ]
                , a
                    [ onClick ChangeEye ]
                    [ img [ class "change", src "../public/eye-button.JPEG" ] [] ]
                , a
                    [ onClick ChangeMouth ]
                    [ img [ class "change", src "../public/mouth-button.JPEG" ] [] ]
                , a
                    [ onClick Move ]
                    [ img [ class "change", src "../public/random.JPEG" ] [] ]

                -- , a
                --     [ onClick Move ]
                --     [ img [ class "change", src "../public/move.JPEG" ] [] ]
                , a
                    [ onClick Stop ]
                    [ text "とめる" ]
                ]
            , div
                [ class "phrase-input" ]
                [ input [ placeholder "くちぐせを入れてね", value model.phrase, onInput Phrase ] []
                ]
            ]
        , div [ class "generate" ]
            [ viewFaceImg model
            , viewEyeImg model
            , viewMouthImg model
            , h1 [] [ validatePhrase model ]
            ]
        , div [] [ showImgButton model ]
        , div []
            [ img [ id "new-img" ] []
            , a [ id "download", download "output.PNG" ] [ text "画像をダウンロード" ]
            ]
        , div []
            [ canvas [ id "generate-canvas" ] [] ]
        ]


validatePhrase : Model -> Html Msg
validatePhrase model =
    if model.phrase == "ワロタ" || model.phrase == "わろた" then
        text "著作権的なアレでダメです"

    else
        text model.phrase


viewFaceImg : Model -> Html Msg
viewFaceImg model =
    if modBy 2 model.face == 0 then
        img [ class "face", src <| "../public/warota" ++ String.fromInt (modBy 2 model.color) ++ ".PNG" ] []

    else
        img [ class "face", src <| "../public/a-ne" ++ String.fromInt (modBy 2 model.color) ++ ".PNG" ] []


viewEyeImg : Model -> Html Msg
viewEyeImg model =
    img [ class <| "eye" ++ String.fromInt (modBy 5 model.eye), src "../public/eye.PNG" ] []


viewMouthImg : Model -> Html Msg
viewMouthImg model =
    img [ class "mouth", src <| "../public/mouth" ++ String.fromInt (modBy 3 model.mouth) ++ ".PNG" ] []


showImgButton : Model -> Html Msg
showImgButton model =
    if model.isCreatedImg then
        button [ onClick Reset ] [ text "リセット" ]

    else
        button [ onClick ToImg ] [ text "画像に変換" ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
