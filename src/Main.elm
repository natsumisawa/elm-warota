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
    , isPousedRandom : Bool
    , isPousedMove : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" 1 1 1 1 False True True, Cmd.none )



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
    | ToggleRandom
    | RandomEveryOneSec Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ face, color, eye, mouth, phrase, isPousedMove, isPousedRandom } as model) =
    case msg of
        Phrase input ->
            ( { model | phrase = input }, Cmd.none )

        ChangeFace ->
            ( { model | face = face + 1 }, Cmd.none )

        ChangeColor ->
            ( { model | color = color + 1 }, Cmd.none )

        ChangeEye ->
            ( { model | eye = eye + 1 }, Cmd.none )

        ChangeMouth ->
            ( { model | mouth = mouth + 1 }, Cmd.none )

        ToImg ->
            ( { model | isCreatedImg = True }, toImg [ phrase, getFaceNum face, String.fromInt <| modBy 2 color, String.fromInt <| modBy 3 mouth ] )

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

        ToggleRandom ->
            ( { model | isPousedRandom = not isPousedRandom }, Cmd.none )

        RandomEveryOneSec time ->
            ( model, Random.generate NewFace (Random.int 1 10) )

        Move ->
            ( { model | phrase = "動くようになるよ", isPousedMove = not isPousedMove }, Cmd.none )



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
    if model.isPousedRandom then
        Sub.none

    else
        Time.every 100 RandomEveryOneSec



---- VIEW ----


view : Model -> Html Msg
view { phrase, face, color, eye, mouth, isCreatedImg } =
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
        , div [ class "generate" ]
            [ viewFaceImg face color
            , viewEyeImg eye
            , viewMouthImg mouth
            , h1 [] [ validatePhrase phrase ]
            ]
        , div [] [ showImgButton isCreatedImg ]
        , div []
            [ img [ id "new-img" ] []
            , a [ id "download", download "output.PNG" ] [ text "画像をダウンロード" ]
            ]
        , div []
            [ canvas [ id "generate-canvas" ] [] ]
        ]


validatePhrase : String -> Html Msg
validatePhrase phrase =
    if phrase == "ワロタ" || phrase == "わろた" then
        text "著作権的なアレでダメです"

    else
        text phrase


viewFaceImg : Int -> Int -> Html Msg
viewFaceImg face color =
    if modBy 2 face == 0 then
        img [ class "face", src <| "../public/warota" ++ String.fromInt (modBy 2 color) ++ ".PNG" ] []

    else
        img [ class "face", src <| "../public/a-ne" ++ String.fromInt (modBy 2 color) ++ ".PNG" ] []


viewEyeImg : Int -> Html Msg
viewEyeImg eye =
    img [ class <| "eye" ++ String.fromInt (modBy 5 eye), src "../public/eye.PNG" ] []


viewMouthImg : Int -> Html Msg
viewMouthImg mouth =
    img [ class "mouth", src <| "../public/mouth" ++ String.fromInt (modBy 3 mouth) ++ ".PNG" ] []


showImgButton : Bool -> Html Msg
showImgButton isCreatedImg =
    if isCreatedImg then
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
