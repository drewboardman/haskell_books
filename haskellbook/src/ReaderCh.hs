{-# LANGUAGE InstanceSigs #-}

module ReaderCh where

import           Control.Applicative
import           Data.Char

boop :: Num a => a -> a
boop = (* 2)

doop :: Num a => a -> a
doop = (+ 10)

bip :: Num a => a -> a
bip = boop <$> doop

bip2 :: Num a => a -> a
bip2 = boop . doop

bbop :: Num a => a -> a
bbop = (+) <$> boop <*> doop

duwop :: Num a => a -> a
duwop = liftA2 (+) boop doop

boopDoop :: Num a => a -> a
boopDoop = do
  b <- boop
  d <- doop
  pure $ b + d

-- -------- exercise ---------
cap :: [Char] -> [Char]
cap xs = toUpper <$> xs

rev :: [Char] -> [Char]
rev xs = reverse xs

composed :: [Char] -> [Char]
composed = cap . rev

fmapped :: [Char] -> [Char]
fmapped = cap <$> rev

tupled :: [Char] -> ([Char], [Char])
tupled = liftA2 td cap rev
  where
    td x y = (x, y)

tupled' :: [Char] -> ([Char], [Char])
tupled' = (\x y -> (x, y)) <$> cap <*> rev

tupledM :: [Char] -> ([Char], [Char])
tupledM = do
  capped  <- cap
  flipped <- rev
  pure (capped, flipped)

tupledM' :: [Char] -> ([Char], [Char])
tupledM' = cap >>= (\x -> rev >>= (\y -> pure (x, y)))

-----------------------------------------------------
newtype Reader' r a = Reader' { runReader :: r -> a }

instance Functor (Reader' r) where
  fmap :: (a -> b) -> Reader' r a -> Reader' r b
  fmap f (Reader' ra) = Reader' (\r -> f (ra r))
  -- fmap f (Reader' ra) = Reader' (f . ra)

ask :: Reader' a a
ask = Reader' (\a -> a)
-- ask = Reader' id

instance Applicative (Reader' r) where
  pure :: a -> Reader' r a
  pure a = Reader' (\_ -> a)
  -- pure a = Reader' (const a)

  (<*>) :: Reader' r (a -> b) -> Reader' r a -> Reader' r b
  -- (Reader' f) <*> (Reader' ra) = Reader' (\r -> (f r) (ra r))
  (Reader' f) <*> (Reader' ra) = Reader' (f <*> ra)

-----------------------------------------------------
newtype HumanName = HumanName String deriving (Eq, Show)

newtype DogName = DogName String deriving (Eq, Show)

newtype Address = Address String deriving (Eq, Show)

data Person = Person { humanName :: HumanName
                     , dogName :: DogName
                     , address :: Address
                     } deriving (Eq, Show)

data Dog = Dog { dogsName :: DogName
               , dogsAddress :: Address
               } deriving (Eq, Show)

getDog :: Person -> Dog
getDog pers = Dog (dogName pers) (address pers)

-- most intuitive
getDogR :: Person -> Dog
getDogR = liftA2 Dog dogName address

-- slightly less intuitive
getDogR' :: Person -> Dog
getDogR' = Dog . dogName <*> address

-- least intuitive
getDogR'' :: Person -> Dog
getDogR'' = Dog <$> dogName <*> address

-- -------- exercise ---------
myLiftA2
  :: Applicative m
  => (a -> b -> c)
  -> m a
  -> m b
  -> m c
myLiftA2 f x y = f <$> x <*> y

myLiftA3
  :: Applicative m
  => (a -> b -> c -> d)
  -> m a
  -> m b
  -> m c
  -> m d
myLiftA3 f x y z = f <$> x <*> y <*> z

asks' :: (r -> a) -> Reader' r a
asks' f = Reader' f
