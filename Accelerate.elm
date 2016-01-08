module Accelerate where

-- IMPORTS
import Html exposing (..)
import Effects
import String
import Signal
import StartApp as StartApp

type alias Point = {x:Float, y:Float, z:Float}

-- PORTS
port acceleration : Signal Point

-- MODEL
type alias Model = List Point

initialModel : Model
initialModel = []

type Action = NoOp | AddPoint Point

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    AddPoint point ->
       point :: model

-- VIEW

view address model =
  div [] [ text <| toString  model ]

inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp

state : Signal Model
state =
  Signal.foldp update initialModel actions

actions : Signal Action
actions =
  Signal.merge inbox.signal (Signal.map AddPoint acceleration)

main =
  Signal.map (view inbox.address) state
