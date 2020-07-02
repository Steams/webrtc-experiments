module Route exposing (Route(..), fromUrl, replaceUrl, toUrl)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, string, top)


type Route
    = BasicChat
    | BasicCanvasBroadcast
    | BasicCanvasConsume


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map BasicChat top
        , Parser.map BasicChat (s "basicchat")
        , Parser.map BasicCanvasBroadcast (s "basicCanvasBroadcast")
        , Parser.map BasicCanvasConsume (s "basicCanvasConsume")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


toUrl : Route -> String
toUrl route =
    let
        pathSegments =
            case route of

                BasicChat ->
                    [ "basicchat" ]

                BasicCanvasBroadcast ->
                    [ "basicCanvasBroadcast" ]

                BasicCanvasConsume ->
                    [ "basicCanvasConsume" ]
    in
    "/" ++ String.join "/" pathSegments


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (toUrl route)
