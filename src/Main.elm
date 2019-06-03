port module Main exposing (Face(..), Model, Msg(..), Parts, init, main, partsEncoder, update, validatePhrase, view, viewEyeImg, viewFaceImg, viewMouthImg)

import Browser
import Html exposing (Attribute, Html, a, button, canvas, div, h1, h3, img, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as JE
import Random
import Task
import Time


port drawImage : JE.Value -> Cmd msg


port resetImg : String -> Cmd msg



---- MODEL ----


type alias Model =
    { parts : Parts
    , hue : Int
    , phrase : String
    , isCreatedImg : Bool
    , isPousedRandom : Bool
    , isBuruburu : Bool
    }


type alias Rgb =
    { red : Int
    , green : Int
    , blue : Int
    }


type alias Parts =
    { face : Face
    , eye : Int
    , mouth : Int
    }


type Face
    = Warota
    | Ane


init : ( Model, Cmd Msg )
init =
    ( Model (Parts Warota 0 0) 0 "" False True False, Cmd.none )



---- UPDATE ----


type Msg
    = ChangePhrase String
    | ChangeFace
    | ChangeColorRandom
    | ChangedColor Int
    | ChangeEye
    | ChangeMouth
    | SendImgToCanvas
    | ResetImg
    | MoveParts
    | ToggleGenerateWarotaRandomly
    | GenerateWarotaRandomly Time.Posix
    | GeneratedParts Parts


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ parts, hue, phrase, isPousedRandom, isBuruburu } as model) =
    let
        { face, eye, mouth } =
            parts
    in
    case msg of
        ChangePhrase input ->
            ( { model | phrase = input }, Cmd.none )

        ChangeFace ->
            let
                newFace =
                    case face of
                        Warota ->
                            Ane

                        Ane ->
                            Warota
            in
            ( { model | parts = Parts newFace eye mouth }, Cmd.none )

        ChangeColorRandom ->
            ( model, generateRandomColor )

        ChangedColor newDeg ->
            ( { model | hue = newDeg }, Cmd.none )

        ChangeEye ->
            ( { model | parts = Parts face (eye + 1) mouth }, Cmd.none )

        ChangeMouth ->
            ( { model | parts = Parts face eye (mouth + 1) }, Cmd.none )

        SendImgToCanvas ->
            ( { model | isCreatedImg = True }, drawImage <| partsEncoder parts hue phrase )

        ResetImg ->
            ( { model | isCreatedImg = False }, resetImg "リセット" )

        ToggleGenerateWarotaRandomly ->
            ( { model | isPousedRandom = not isPousedRandom }, Cmd.none )

        GenerateWarotaRandomly _ ->
            ( { model | isCreatedImg = False }, Cmd.batch [ generateRandomParts, generateRandomColor ] )

        GeneratedParts p ->
            ( { model | parts = p }, Cmd.none )

        MoveParts ->
            ( { model | isBuruburu = not isBuruburu }, Cmd.none )


partsEncoder : Parts -> Int -> String -> JE.Value
partsEncoder parts hue phrase =
    let
        { face, eye, mouth } =
            parts

        faceFileName =
            case face of
                Warota ->
                    "warota"

                Ane ->
                    "a-ne"
    in
    JE.object
        [ ( "face", JE.string faceFileName )
        , ( "hue", JE.int hue )
        , ( "eye", JE.int <| modBy 5 eye )
        , ( "mouth", JE.int <| modBy 3 mouth )
        , ( "phrase", JE.string phrase )
        ]


generateRandomColor : Cmd Msg
generateRandomColor =
    Random.generate ChangedColor <| Random.int 0 360


generateRandomParts : Cmd Msg
generateRandomParts =
    Random.generate GeneratedParts (Random.map3 Parts (Random.uniform Warota [ Ane ]) (Random.int 0 5) (Random.int 0 2))



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.isPousedRandom then
        Sub.none

    else
        Time.every 100 GenerateWarotaRandomly



---- VIEW ----


view : Model -> Html Msg
view { phrase, parts, isCreatedImg, isBuruburu, hue } =
    div []
        [ div [ class "header" ]
            [ h1 []
                [ text "ワロタジェネレーター" ]
            , div [ class "change-button" ]
                [ a
                    [ onClick ChangeFace ]
                    [ img [ class "change", src "../public/warota-face.JPEG" ] [] ]
                , a
                    [ onClick ChangeColorRandom ]
                    [ img [ class "change", src "../public/color-button.JPEG" ] [] ]
                , a
                    [ onClick ChangeEye ]
                    [ img [ class "change", src "../public/eye-button.JPEG" ] [] ]
                , a
                    [ onClick ChangeMouth ]
                    [ img [ class "change", src "../public/mouth-button.JPEG" ] [] ]
                , a
                    [ onClick ToggleGenerateWarotaRandomly ]
                    [ img [ class "change", src "../public/random.JPEG" ] [] ]
                , a
                    [ onClick MoveParts ]
                    [ img [ class "change", src "../public/move.JPEG" ] [] ]
                ]
            , div
                [ class "phrase-input" ]
                [ input [ placeholder "くちぐせを入れてね", value phrase, onInput ChangePhrase ] []
                ]
            ]
        , div []
            [ viewGenerate isBuruburu phrase parts hue
            , div [] [ showImgButton isCreatedImg ]
            , div []
                [ img [ id "new-img" ] []
                , a [ id "download", download "output.PNG" ] [ text "画像をダウンロード" ]
                ]
            , div []
                [ canvas [ id "generate-canvas", width 400, height 450 ] [] ]
            ]
        ]


viewGenerate : Bool -> String -> Parts -> Int -> Html Msg
viewGenerate isBuruburu phrase parts hue =
    let
        { face, eye, mouth } =
            parts
    in
    if isBuruburu then
        div [ class "generate", id "buruburu" ]
            [ viewFaceImg face hue
            , viewEyeImg eye
            , viewMouthImg mouth
            , h1 [] [ validatePhrase phrase ]
            ]

    else
        div [ class "generate" ]
            [ viewFaceImg face hue
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
viewFaceImg face hue =
    let
        newFace =
            case face of
                Warota ->
                    "warota"

                Ane ->
                    "a-ne"
    in
    img [ class "face", style "background" <| "hsla(" ++ String.fromInt hue ++ ", 94%, 49%, 1.0)", src <| "../public/" ++ newFace ++ ".PNG" ] []


viewEyeImg : Int -> Html Msg
viewEyeImg eye =
    img [ class "eye", src <| "../public/eye" ++ String.fromInt (modBy 5 eye) ++ ".PNG" ] []


viewMouthImg : Int -> Html Msg
viewMouthImg mouth =
    img [ class "mouth", src <| "../public/mouth" ++ String.fromInt (modBy 3 mouth) ++ ".PNG" ] []


showImgButton : Bool -> Html Msg
showImgButton isCreatedImg =
    if isCreatedImg then
        button [ onClick ResetImg ] [ text "リセット" ]

    else
        button [ onClick SendImgToCanvas ] [ text "画像に変換" ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
