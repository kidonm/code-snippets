{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE RecordWildCards #-}
module GMachine.Type.Heap where

import Data.Word (Word32)

import qualified Data.Map as M (Map, empty, insert)

import Control.Lens (Lens', (^.), (&), (%~), (.~), at, makeLenses)
import Control.Lens.Iso (anon)
import Text.PrettyPrint
import Text.PrettyPrint.HughesPJClass

import GMachine.Type.Address (Address(Addr))


data Heap a = Heap
    { _heapSize :: Word32
    , _freeCells :: [Int]
    , _heapData :: M.Map Int a
    }
makeLenses ''Heap

instance Show a => Show (Heap a) where
    show = show . _heapData

hAlloc :: Heap a -> a -> (Address, Heap a)
hAlloc heap@Heap{..} v = (Addr $ heap ^. heapSize, heap
    & heapSize %~ succ
    & freeCells %~ tail
    & heapData %~ (M.insert (head _freeCells) v))

hLookup :: Heap a -> Int -> a
hLookup heap a = heap ^. heapData.at a._fromJust

hInitial :: Heap a
hInitial = Heap
    { _heapSize = 0
    , _freeCells = [0..]
    , _heapData = M.empty
    }

hSetAt :: Int -> a -> Heap a -> Heap a
hSetAt index addr heap = heap & heapData.at index._fromJust .~ addr

_fromJust :: Lens' (Maybe a) a
_fromJust = anon (error "_fromJust: Nothing") (\_ -> False)
