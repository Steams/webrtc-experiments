module Layout exposing (Layout(..), TitleAndContent, render)

import Browser exposing (Document)
import Element exposing (..)
import Route exposing (Route)
import Styles


type Layout
    = Other
    | BasicChat
    | BasicCanvasBroadcast
    | BasicCanvasConsume


type alias TitleAndContent msg =
    { title : String, content : Element msg }


render : Layout -> TitleAndContent msg -> Document msg
render layout page =
    let
        build content =
            Element.layoutWith
                { options =
                    [ focusStyle
                        { borderColor = Nothing
                        , backgroundColor = Nothing
                        , shadow = Nothing
                        }
                    ]
                }
                [ height fill, width fill ]
                (view_container layout content)
    in
    { title = page.title
    , body = [ build page.content ]
    }


view_container : Layout -> Element msg -> Element msg
view_container layout content =
    Element.column
        [ width fill ]
        [ header layout
        , content
        ]


header : Layout -> Element msg
header layout =
    Element.row Styles.nav_bar
        [ navLink layout Route.BasicChat <| Element.el Styles.nav_item <| Element.text "Basic Chat"
        , navLink layout Route.BasicCanvasBroadcast <| Element.el Styles.nav_item <| Element.text "Basic Canvas Broadcast"
        , navLink layout Route.BasicCanvasConsume <| Element.el Styles.nav_item <| Element.text "Basic Canvas Consume"
        ]


navLink layout route label =
    case isActive layout route of
        True ->
            Element.link Styles.active_nav_item { url = Route.toUrl route, label = label }

        False ->
            Element.link Styles.inactive_nav_item { url = Route.toUrl route, label = label }


isActive layout route =
    case ( layout, route ) of
        ( BasicChat, Route.BasicChat ) ->
            True

        ( BasicCanvasBroadcast, Route.BasicCanvasBroadcast ) ->
            True

        ( BasicCanvasConsume, Route.BasicCanvasConsume ) ->
            True

        _ ->
            False
