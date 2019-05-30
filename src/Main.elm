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
    { parts : Parts
    , phrase : String
    , isCreatedImg : Bool
    , isPousedRandom : Bool
    , isBuruburu : Bool
    }


type alias Parts =
    { face : Face
    , color : Int
    , eye : Int
    , mouth : Int
    }


type Face
    = Warota
    | Ane


init : ( Model, Cmd Msg )
init =
    ( Model (Parts Warota 1 1 1) "" False True False, Cmd.none )



---- UPDATE ----


type Msg
    = Phrase String
    | ChangeFace
    | ChangeColor
    | ChangeEye
    | ChangeMouth
    | ToImg
    | Reset
    | PartsGenerator Parts
    | Move
    | ToggleRandom
    | RandomEveryOneSec Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ parts, phrase, isPousedRandom, isBuruburu } as model) =
    let
        { face, color, eye, mouth } =
            parts
    in
    case msg of
        Phrase input ->
            ( { model | phrase = input }, Cmd.none )

        ChangeFace ->
            case face of
                Warota ->
                    ( { model | parts = Parts Ane color eye mouth }, Cmd.none )

                Ane ->
                    ( { model | parts = Parts Warota color eye mouth }, Cmd.none )

        ChangeColor ->
            ( { model | parts = Parts face (color + 1) eye mouth }, Cmd.none )

        ChangeEye ->
            ( { model | parts = Parts face color (eye + 1) mouth }, Cmd.none )

        ChangeMouth ->
            ( { model | parts = Parts face color eye (mouth + 1) }, Cmd.none )

        ToImg ->
            case face of
                Warota ->
                    ( { model | isCreatedImg = True }, toImg [ phrase, "warota", String.fromInt color, String.fromInt mouth ] )

                Ane ->
                    ( { model | isCreatedImg = True }, toImg [ phrase, "a-ne", String.fromInt color, String.fromInt mouth ] )

        Reset ->
            ( { model | isCreatedImg = False }, resetImg "リセット" )

        ToggleRandom ->
            ( { model | isPousedRandom = not isPousedRandom }, Cmd.none )

        RandomEveryOneSec time ->
            ( { model | isCreatedImg = False }, Random.generate PartsGenerator (Random.map4 Parts (Random.uniform Warota [ Ane ]) (Random.int 0 1) (Random.int 0 4) (Random.int 0 2)) )

        PartsGenerator p ->
            ( { model | parts = p }, Cmd.none )

        Move ->
            ( { model | isBuruburu = not isBuruburu }, Cmd.none )



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.isPousedRandom then
        Sub.none

    else
        Time.every 100 RandomEveryOneSec



---- VIEW ----


view : Model -> Html Msg
view { phrase, parts, isCreatedImg, isBuruburu } =
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
                    [ onClick ToggleRandom ]
                    [ img [ class "change", src "../public/random.JPEG" ] [] ]
                , a
                    [ onClick Move ]
                    [ img [ class "change", src "../public/move.JPEG" ] [] ]
                ]
            , div
                [ class "phrase-input" ]
                [ input [ placeholder "くちぐせを入れてね", value phrase, onInput Phrase ] []
                ]
            ]
        , viewGenerate isBuruburu phrase parts
        , div [] [ showImgButton isCreatedImg ]
        , div []
            [ img [ id "new-img" ] []
            , a [ id "download", download "output.PNG" ] [ text "画像をダウンロード" ]
            ]
        , div []
            [ canvas [ id "generate-canvas", width 350, height 400 ] [] ]
        ]


viewGenerate : Bool -> String -> Parts -> Html Msg
viewGenerate isBuruburu phrase parts =
    let
        { face, color, eye, mouth } =
            parts
    in
    if isBuruburu then
        div [ class "generate", id "buruburu" ]
            [ viewFaceImg face color
            , viewEyeImg eye
            , viewMouthImg mouth
            , h1 [] [ validatePhrase phrase ]
            ]

    else
        div [ class "generate" ]
            [ viewFaceImg face color
            , viewEyeImg eye
            , viewMouthImg mouth
            , h1 [] [ validatePhrase phrase ]
            ]


validatePhrase : String -> Html Msg
validatePhrase phrase =
    if phrase == "ワロタ" || phrase == "わろた" then
        text "著作権的なアレでダメです"

    else
        text phrase


viewFaceImg : Face -> Int -> Html Msg
viewFaceImg face color =
    case face of
        Warota ->
            img [ class "face", src <| "../public/warota" ++ String.fromInt color ++ ".PNG" ] []

        Ane ->
            img [ class "face", src <| "../public/a-ne" ++ String.fromInt color ++ ".PNG" ] []


viewEyeImg : Int -> Html Msg
viewEyeImg eye =
    img [ class <| "eye" ++ String.fromInt eye, src "../public/eye.PNG" ] []


viewMouthImg : Int -> Html Msg
viewMouthImg mouth =
    img [ class "mouth", src <| "../public/mouth" ++ String.fromInt mouth ++ ".PNG" ] []


showImgButton : Bool -> Html Msg
showImgButton isCreatedImg =
    if isCreatedImg then
        button [ onClick Reset ] [ text "リセット" ]

    else
        button [ onClick ToImg ] [ text "画像に変換(2秒後に表示されます)" ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
