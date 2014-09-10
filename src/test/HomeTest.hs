{-# LANGUAGE OverloadedStrings, NoMonomorphismRestriction, GADTs, TemplateHaskell #-}

module HomeTest where

import Control.Applicative
import Control.Lens
import Data.ByteString (ByteString)
import Data.Text (Text, unpack)
import Data.Maybe (fromMaybe)
import qualified Data.Map as M
import Snap (Handler, method, Method(..), writeText, writeBS,
                getParam, SnapletInit, makeSnaplet, addRoutes,
                route, liftIO, void)
import qualified Snap as Snap
import Control.Concurrent.Async (async)
import Control.Concurrent.MVar (MVar, newEmptyMVar, tryPutMVar, tryTakeMVar, isEmptyMVar)
import qualified System.IO.Streams as Stream
import qualified System.IO.Streams.Concurrent as Stream
import System.Exit (exitSuccess, exitFailure)
import Snap.Test.BDD

import Application
homeTests :: SnapTesting App ()
homeTests = do
    name "should open main page" $ do
        should $ succeed <$> get "/login"
    name "should not found /omgPage" $ do
        should $ notfound <$> get "/omgPage"

