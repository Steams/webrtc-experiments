module Pages.BasicChat exposing (Model, Msg, init, update, view)

import Browser.Navigation exposing (pushUrl)
import Element exposing (..)

import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Element.Border as Border
import Html
import Html.Attributes as HtmlA
import Json.Encode as E
import Layout exposing (TitleAndContent)
import Ports as Ports
import RemoteData exposing (RemoteData(..), WebData)
import Route
import Styles



-- Model
-- { session : Session, contacts : List Contact }


type alias Model =
    { id : String, call : String}



-- State


type Msg
    = NoOp
    | IdInput String
    | CallInput String
    | Register
    | Go


-- init : Session -> ( Model, Cmd Msg )
init : () -> ( Model, Cmd Msg )
init _ =
    ( {id = "", call = ""}, Ports.initBasicChat (E.string "") )
    -- ( { id = "" , call = ""}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IdInput val ->
            ( { model | id = val }
            , Cmd.none
            )

        CallInput val ->
            ( { model | call = val }
            , Cmd.none
            )

        Register ->
            ( model , Ports.register model.id)

        Go ->
            ( model , Ports.call model.call)

        _ ->
            ( model
            , Cmd.none
            )



-- View


input placeholder handler value =
    Input.text
        [ width (px 400)
        , height (px 65)
        ]
        { onChange = handler
        , text = value
        , placeholder = Just (Input.placeholder [] <| el [ centerY, Font.color (rgb255 200 200 200) ] <| text placeholder)
        , label = Input.labelHidden ""
        }


button value handler =
    Input.button
        [ height (px 55)
        , width (px 150)
        , Border.width 1
        , Font.size 12
        , Font.center
        , Font.bold
        ]
        { onPress = Just handler
        , label = text value
        }

register_container model =
    Element.row []
        [ input "register id" IdInput model.id
        , button "Register" Register
        , input "Call @id" CallInput model.call
        , button "Join Call" Go
        ]

self_cam =
    Element.el [ alignRight, height (px 300), width (px 400), Background.color (rgb255 0 0 0)] <| html <| Html.video [ HtmlA.id "selfCam", HtmlA.attribute "autoplay" "", HtmlA.attribute "playsinline" "", HtmlA.width 400, HtmlA.height 300 ] []

other_cam =
    Element.el [height fill,width fill] <| html <| Html.video [ HtmlA.style "height" "100%", HtmlA.style "width" "100%", HtmlA.id "otherCam", HtmlA.attribute "autoplay" "", HtmlA.attribute "playsinline" "" ] []

video_container =
    Element.column [ inFront self_cam, height (px 900), width (px 1400), Background.color (rgb255 37 48 178), clip]
        [ other_cam
        ]


render model =
    Element.column [centerX]
        [ text "Basic chat"
        , video_container
        , register_container model
        ]


view : Model -> TitleAndContent Msg
view model =
    { title = "Contacts"
    , content = render model
    }



edges =
    { bottom = 0
    , left = 0
    , right = 0
    , top = 0
    }
