{-# LANGUAGE OverloadedStrings #-}

module Heist.Splices.Camellia.Types where

------------------------------------------------------------------------------

import Data.Map.Syntax
import Data.Text (Text)
import Data.List (intercalate)
import Data.List.Split (chunksOf)
import Data.Monoid ((<>))
import qualified Data.Text as T
import Heist.Interpreted

-- for examining the Nodes
import Heist (getParamNode)
import qualified Text.XmlHtml as X hiding (render)

-- for dates
import Data.Time.Format
import System.Locale

------------------------------------------------------------------------------

stringSplice :: (Monad m) => String -> Splice m
stringSplice = textSplice . T.pack

showSplice :: (Monad m, Show a) => a -> Splice m
showSplice = stringSplice . show

numericSplice :: (Num a, Show a, Monad m) => a -> Splice m
numericSplice = stringSplice . show

listSplice :: Monad m => Text -> [Text] -> Splice m
listSplice tag = mapSplices (\ x -> runChildrenWith $ tag ## textSplice x)

dateFormatSplice :: (Monad m, FormatTime t) => TimeLocale -> String -> t -> Splice m
dateFormatSplice locale defaultFormat t = do
	node <- getParamNode
	let
		format = maybe defaultFormat T.unpack $ X.getAttribute "format" node
	textSplice $ T.pack $ formatTime locale format t

-- this converts a number to a comma delimited number
prettyNumberSplice :: (Monad m, Num n, Show n) => n -> Splice m
prettyNumberSplice i =
	let
		(whole, decimal) = break (== '.') $ show i
		commaWhole = reverse $ intercalate "," $ chunksOf 3 $ reverse whole
		dotHalf = if not (null decimal) then '.' : decimal else []
	in stringSplice $ commaWhole <> dotHalf
