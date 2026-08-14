{-# LANGUAGE QualifiedDo #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE UnboxedTuples #-}

module Main where

import Test.Inspection
import With.Internal as With

bind :: (Monad m) => m a -> (a -> m b) -> m b
bind m f = With.do x <- m; f x

bind' :: (Monad m) => m a -> (a -> m b) -> m b
bind' m f = do x <- m; f x

then_ :: (Monad m) => m a -> m b -> m b
then_ m n = With.do m; n

then_' :: (Monad m) => m a -> m b -> m b
then_' m n = do m; n

with0 :: (a -> r) -> a -> r
with0 f x = With.do with f; x

with0' :: (a -> r) -> a -> r
with0' f x = f x

with1 :: ((a -> b) -> r) -> (a -> b) -> r
with1 f g = With.do x <- with f; g x

with1' :: ((a -> b) -> r) -> (a -> b) -> r
with1' f g = f (\a -> g a)

with2 :: ((a -> b -> c) -> r) -> ((# a, b #) -> c) -> r
with2 f g = With.do x <- with f; g x

with2' :: ((a -> b -> c) -> r) -> ((# a, b #) -> c) -> r
with2' f g = f (\a b -> g (# a, b #))

inspect $ 'bind === 'bind'
inspect $ 'then_ === 'then_'
inspect $ 'with0 === 'with0'
inspect $ 'with1 === 'with1'
inspect $ 'with2 === 'with2'

main :: IO ()
main = pure ()
