module Pages.BasicCanvasConsume exposing (Model, Msg, init, update, view)

import Browser.Navigation exposing (pushUrl)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
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
    { id : String, call : String }



-- State


type Msg
    = NoOp
    | Join


-- init : Session -> ( Model, Cmd Msg )
init : () -> ( Model, Cmd Msg )
init _ =
    -- ( { id = "222", call = "111" }, Ports.initCanvasConsume "" )
    ( { id = "", call = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Join ->
            ( model, Ports.basicCanvasConsumeJoin ""  )
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


vid =
    Element.el [ alignRight, height (px 500), width (px 900), Background.color (rgb255 0 0 0) ] <|
        html <|
            Html.video
                [ HtmlA.id "videoConsume"
                , HtmlA.attribute "autoplay" ""
                , HtmlA.attribute "playsinline" ""
                , HtmlA.width 900
                , HtmlA.height 500
                ]
                []

video_container =
    Element.column []
        [ vid
        ]


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

render model =
    Element.column [ centerX ]
        [ text "Basic canvas consumer"
        , video_container
        , button "Consume Stream" Join
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
