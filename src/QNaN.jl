module QNaN

export qnan, isqnan, isqnanPos, isqnanNeg, isjnan

#=
  A float64 quiet NaN is represented with these 2^52-2 UInt64 hexadecimal patterns:
  (positive) UnitRange(0x7ff8000000000000,0x7fffffffffffffff) has 2^51-1 realizations
  (negative) UnitRange(0xfff8000000000000,0xffffffffffffffff) has 2^51-1 realizations

  A float32 quiet NaN is represented with these 2^23-2 UInt32 hexadecimal patterns:
  (positive) UnitRange(0x7fc00000,0x7fffffff) has 2^22-1 realizations
  (negative) UnitRange(0xffc00000,0xffffffff) has 2^22-1 realizations

  A float16 quiet NaN is represented with these 2^10-2 UInt16 hexadecimal patterns:
  (positive) UnitRange(0x7e00,0x7fff) has 2^9-1 realizations
  (negative) UnitRange(0xfe00,0xffff) has 2^9-1 realizations

  Julia appears to assign as NaNs (generally denoting an Indeterminacy)
  0xfff8000000000000, 0xffc00000, 0xfe00, 0x7ff8000000000000, 0x7fc00000, 0x7e00
  Preferring not to give that more than one use, they excluded from settable QNaNs.
=#

for (FL, I, UI, UPos, UNeg) in [(:Float64, :Int64, :UInt64, :0x7ff8000000000000, :0xfff8000000000000),
                                (:Float32, :Int32, :UInt32, :0x7fc00000, :0xffc00000),
                                (:Float16, :Int16, :UInt16, :0x7e00, :0xfe00) ]
  @eval begin
      @inline isjnan(x::$(UI))    = (x == $(UNeg)) || (x == $(UPos))
      @inline isqnan(x::$(UI))    = (x & $(UPos)) == $(UPos)
      @inline isqnanPos(x::$(UI)) = (x & $(UNeg)) == $(UPos)
      @inline isqnanNeg(x::$(UI)) = (x & $(UNeg)) == $(UNeg)
      @inline isjnan(x::$(FL))    = isjnan(reinterpret($(UI),x))
      @inline isqnan(x::$(FL))    = isqnan(reinterpret($(UI),x))
      @inline isqnanPos(x::$(FL)) = isqnanPos(reinterpret($(UI),x))
      @inline isqnanNeg(x::$(FL)) = isqnanNeg(reinterpret($(UI),x))

      function qnan(si::$(I))
          u = reinterpret($(UI), abs(si))
          if (u & ~$(UPos)) == 0
              throw(ArgumentError("The magnitude of n cannot be 0, that NaN is used by Julia."))
          elseif (u > ~$(UNeg)) # 2^51-1
              throw(ArgumentError("The magnitude of n $(si) exceeds available QNaN."))
          end
          u |= ((si > 0) ? $(UPos) : $(UNeg))
          reinterpret($(FL),u)
      end

      function qnan(fp::$(FL))
          u = reinterpret($(UI), fp)
          if !isqnan(u)
              throw(ArgumentError("The value $(fp) ($(u)) is not a QNaN."))
          end
          a = u & ~$(UNeg)
          b =  reinterpret($(I),a)
          (((u & ($(UPos) $ $(UNeg))) == 0) ? b : -b)
      end
  end
end

@doc """
Module QNaN


  qnan(**si**::{Int16|32|64}) generates a QNaN with signed payload of **si**


  qnan(**fp**::AbstractFloat) recovers the signed payload from **fp**


  isqnan(**fp**::AbstractFloat) true iff **fp** is any QNaN


  isjnan(**fp**::AbstractFloat) true iff **fp** is a QNaN that Julia uses


  isqnanPos(**fp**::AbstractFloat) true iff isqnan(**fp**) and !signbit(**fp**)


  isqnanNeg(**fp**::AbstractFloat) true iff isqnan(**fp**) and  signbit(**fp**)

""" -> QNaN
