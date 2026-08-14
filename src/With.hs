-- | QualifiedDo notation for mixing monadic actions with [Koka-style with statements](https://koka-lang.github.io/koka/doc/book.html#sec-with).
--
-- > {-# LANGUAGE QualifiedDo #-}
-- > {-# LANGUAGE UnboxedTuples #-}
-- >
-- > import With
-- > import Control.Exception
-- > import Data.Foldable
-- > import Text.Printf
-- >
-- > forPair_ :: (Applicative m) => [(a, b)] -> (a -> b -> m ()) -> m ()
-- > forPair_ xs f = for_ xs (uncurry f)
-- >
-- > main = With.do
-- >   -- ordinary monadic bind and sequencing
-- >   s <- getLine
-- >   print s
-- >   -- with, without binding
-- >   with (`finally` putStrLn "Bye!")
-- >   -- with, binding one argument
-- >   n <- with (for_ [0 :: Int .. 3])
-- >   -- with, binding multiple arguments
-- >   (# k, v #) <- with (forPair_ [("foo", 1), ("bar", 2)])
-- >   printf "n = %d, k = %s, v = %d\n" n k v
--
-- With statements are first-class and can be named and reused.
--
-- > defer :: IO () -> With (IO a -> IO a)
-- > defer cleanup = with (`finally` cleanup)
-- >
-- > main = With.do
-- >   defer (putStrLn "Bye!")
-- >   putStrLn "Hello!"
--
-- == Limitation
--
-- A polymorphic monadic statement whose result could be a function may require additional type information:
--
-- > With.do
-- >   n <- pure 42 :: IO Int
-- >   m <- pure @IO 42 -- with -XTypeApplications
-- >   ...
module With
  ( -- * Core API
    With,
    with,
    (With.Internal.>>=),
    (With.Internal.>>),

    -- * Re-exports
    MonadFail (..),
    MonadFix (..),
  )
where

import Control.Monad.Fix
import With.Internal
