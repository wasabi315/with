{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UnboxedTuples #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE UnliftedNewtypes #-}

-- | Internal API for "With".
module With.Internal
  ( Bind (..),
    Then (..),
    With (..),
    with,
    CurryN (..),
  )
where

import GHC.Exts

infixl 1 >>=

infixl 1 >>

--------------------------------------------------------------------------------

class Bind (a :: TYPE r) b c where
  -- | Generalized monadic bind used by QualifiedDo. See "With".
  --
  -- Instance types include:
  --
  -- @
  -- -- ordinary monadic bind
  -- (>>=) :: 'Monad' m => m a -> (a -> m b) -> m b
  -- -- with, one-argument trailing lambda
  -- (>>=) :: t'With' ((a -> b) -> r) -> (a -> b) -> r
  -- -- with, two-argument trailing lambda
  -- (>>=) :: t'With' ((a -> b -> c) -> r) -> ((# a, b #) -> c) -> r
  -- ...
  -- @
  (>>=) :: a -> b -> c

class Then (a :: TYPE r) b c where
  -- | Generalized monadic sequencing used by QualifiedDo. See "With".
  --
  -- Instance types include:
  --
  -- @
  -- -- ordinary monadic sequencing
  -- (>>) :: 'Monad' m => m a -> m b -> m b
  -- -- with, without binding
  -- (>>) :: t'With' (a -> r) -> a -> r
  -- @
  (>>) :: a -> b -> c

-- Fall back to the standard monad operations

instance (Monad m, a ~ m a', b ~ (a' -> m b'), c ~ m b') => Bind a b c where
  (>>=) = (Prelude.>>=)
  {-# INLINE (>>=) #-}

instance (Monad m, a ~ m a', b ~ m b', c ~ m b') => Then a b c where
  (>>) = (Prelude.>>)
  {-# INLINE (>>) #-}

--------------------------------------------------------------------------------

-- | Marks a function for @with@ semantics.

-- The non-lifted representation of @With@ is important; it keeps with statements
-- distinct from ordinary monadic actions during instance resolution.
newtype With a = With (# a #)

-- | Use a function as a @with@ statement.
with :: a -> With a
with a = With (# a #)
{-# INLINE with #-}

instance (CurryN fn', Curried fn' ~ fn, r ~ r') => Bind (With (fn -> r)) fn' r' where
  With (# f #) >>= g = f (curryN g)
  {-# INLINE (>>=) #-}

instance (a ~ a', r ~ r') => Then (With (a -> r)) a' r' where
  With (# f #) >> x = f x
  {-# INLINE (>>) #-}

class CurryN fn where
  type Curried fn
  curryN :: fn -> Curried fn

-- Main instance
instance CurryN (a -> b) where
  type Curried (a -> b) = a -> b
  curryN = id
  {-# INLINE curryN #-}

-- Support for trailing lambdas with multiple parameters

instance CurryN ((# #) -> a) where
  type Curried ((# #) -> a) = a
  curryN f = f (# #)
  {-# INLINE curryN #-}

instance CurryN ((# a #) -> b) where
  type Curried ((# a #) -> b) = a -> b
  curryN f = \a -> f (# a #)
  {-# INLINE curryN #-}

instance CurryN ((# a, b #) -> c) where
  type Curried ((# a, b #) -> c) = a -> b -> c
  curryN f = \a b -> f (# a, b #)
  {-# INLINE curryN #-}

instance CurryN ((# a, b, c #) -> d) where
  type Curried ((# a, b, c #) -> d) = a -> b -> c -> d
  curryN f = \a b c -> f (# a, b, c #)
  {-# INLINE curryN #-}

instance CurryN ((# a, b, c, d #) -> e) where
  type Curried ((# a, b, c, d #) -> e) = a -> b -> c -> d -> e
  curryN f = \a b c d -> f (# a, b, c, d #)
  {-# INLINE curryN #-}

instance CurryN ((# a, b, c, d, e #) -> f) where
  type Curried ((# a, b, c, d, e #) -> f) = a -> b -> c -> d -> e -> f
  curryN f = \a b c d e -> f (# a, b, c, d, e #)
  {-# INLINE curryN #-}
