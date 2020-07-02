module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Element exposing (..)
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode
import Layout as Layout
import Pages.BasicChat as BasicChat
import Pages.BasicCanvasBroadcast as BasicCanvasBroadcast
import Pages.BasicCanvasConsume as BasicCanvasConsume
import Pages.NotFound as NotFound
import Ports as Ports
import RemoteData as RemoteData exposing (RemoteData(..), WebData)
import Route exposing (Route)
import Task
import Url exposing (Url)
import Session exposing (Session)


type Page
    = Redirect
    | BasicChat BasicChat.Model
    | BasicCanvasBroadcast BasicCanvasBroadcast.Model
    | BasicCanvasConsume BasicCanvasConsume.Model
    | NotFound


type alias Model =
    { session : Session, page : Page }


-- MODEL



-- init : SessionFlags -> Url -> Nav.Key -> ( Model, Cmd Msg ) -- for running via index.html
-- init flags url navKey =
init : () -> Url -> Nav.Key -> ( Model, Cmd Msg ) -- for running via elm-live
init _ url navKey =
    let
        model =
            Model (Session navKey) Redirect
            -- Model (Session "" "" navKey) Redirect
            -- Model (Session.init flags navKey) Redirect

        route =
                Route.fromUrl url
    in
    goto route model



-- UPDATE


type Msg
    = ChangeUrl Url
    | RequestUrl Browser.UrlRequest
    | BasicChatMsg BasicChat.Msg
    | BasicCanvasBroadcastMsg BasicCanvasBroadcast.Msg
    | BasicCanvasConsumeMsg BasicCanvasConsume.Msg
    | NoOp



-- | GotSession Session


goto : Maybe Route -> Model -> ( Model, Cmd Msg )
goto maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.BasicChat ->
            let
                ( m, b_msg ) =
                    BasicChat.init ()
            in
            ( { model | page = BasicChat m }
            , Cmd.map BasicChatMsg b_msg
            )

        Just Route.BasicCanvasBroadcast ->
            let
                ( m, b_msg ) =
                    BasicCanvasBroadcast.init ()
            in
            ( { model | page = BasicCanvasBroadcast m }
            , Cmd.map BasicCanvasBroadcastMsg b_msg
            )

        Just Route.BasicCanvasConsume ->
            let
                ( m, b_msg ) =
                    BasicCanvasConsume.init ()
            in
            ( { model | page = BasicCanvasConsume m }
            , Cmd.map BasicCanvasConsumeMsg b_msg
            )



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( RequestUrl urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.session.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( ChangeUrl url, _ ) ->
            goto (Route.fromUrl url) model

        ( BasicChatMsg subMsg, BasicChat m ) ->
            let
                ( b_model, b_msg ) =
                    BasicChat.update subMsg m
            in
            ( { model | page = BasicChat b_model }
            , Cmd.map BasicChatMsg b_msg
            )

        ( BasicCanvasBroadcastMsg subMsg, BasicCanvasBroadcast m ) ->
            let
                ( b_model, b_msg ) =
                    BasicCanvasBroadcast.update subMsg m
            in
            ( { model | page = BasicCanvasBroadcast b_model }
            , Cmd.map BasicCanvasBroadcastMsg b_msg
            )

        ( BasicCanvasConsumeMsg subMsg, BasicCanvasConsume m ) ->
            let
                ( b_model, b_msg ) =
                    BasicCanvasConsume.update subMsg m
            in
            ( { model | page = BasicCanvasConsume b_model }
            , Cmd.map BasicCanvasConsumeMsg b_msg
            )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []



-- VIEW


view : Model -> Document Msg
view model =
    let
        render : Layout.Layout -> (subMsg -> Msg) -> Layout.TitleAndContent subMsg -> Document Msg
        render layout msg_wrapper page =
            Layout.render layout { title = page.title, content = Element.map msg_wrapper page.content }
    in
    case model.page of
        Redirect ->
            render Layout.Other (\_ -> NoOp) NotFound.view

        NotFound ->
            render Layout.Other (\_ -> NoOp) NotFound.view

        BasicChat m ->
            render Layout.BasicChat BasicChatMsg (BasicChat.view m)

        BasicCanvasBroadcast m ->
            render Layout.BasicCanvasBroadcast BasicCanvasBroadcastMsg (BasicCanvasBroadcast.view m)

        BasicCanvasConsume m ->
            render Layout.BasicCanvasConsume BasicCanvasConsumeMsg (BasicCanvasConsume.view m)



-- MAIN

-- main : Program Session.Flags Model Msg -- for running via index.html
main : Program () Model Msg -- for running via elm-live
main =
    Browser.application
        { init = init
        , onUrlChange = ChangeUrl
        , onUrlRequest = RequestUrl
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
