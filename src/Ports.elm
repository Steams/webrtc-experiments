port module Ports exposing (..)

import Json.Encode as E

port initBasicChat          : E.Value -> Cmd msg
port initCanvasBroadcast    : String  -> Cmd msg
port initCanvasConsume      : String  -> Cmd msg
port basicCanvasConsumeJoin : String  -> Cmd msg
port initialize             : E.Value -> Cmd msg
port register               : String  -> Cmd msg
port call                   : String  -> Cmd msg
