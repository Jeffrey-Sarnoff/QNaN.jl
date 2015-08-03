## QNaN.jl
#####quiet NaNs were designed to propogate information from within numerical computations

Jeffrey Sarnoff at 2015-Aug-02 03:44 UTC in USA>NY>New_York

####Quick Look

```julia
> using QNaN
> anan = qnan(36)
NaN
> typeof(anan)
Float64
> payload = qnan(anan)
36
> anan = qnan(Int32(-77))
NaN32
> payload = qnan(anan); payload, typeof(payload)
-77, Int32
> isqnan(anan), isqnan(NaN)
true, true
> isnan(anan), isnan(NaN)   # they propogate as NaNs
true, true
> isqnan(anan), isjnan(NaN) # Julia's NaNs are discernable
true, false

```
####About QNaN Propogation

A QNaN introduced into a numerical processing sequence usually will propogate along the computational path without loss of identity unless another QNaN is substituted or an second QNaN occurs in an arithmetic expression.

AFAIK Julia propogates the lhs of `-`. When two qnans have propogated to the same function, select qnan1 over qnan2 this way: ```return qnan1 - qnan2```. 

*Note: This behavior is **not** currently available at the top level of the REPL.*

When the information carried is costly to aquire, and one of two payload is usually the more importantd,  a pairing function may propogate more than one payload.  This is easiest whith smaller payloads. Pairing starts with zero and stops as zero is unpaired.  The initial pair: ``pair(pair(zero, first_payload),second_payload)``.


```julia
> using QNaN
> function test_rhs_of_subtract()
    lhs = qnan(-64)
    rhs = qnan(100)
    (qnan(lhs-rhs)==qnan(lhs), qnan(rhs-lhs)==qnan(rhs))
  end;
> test_rhs_of_subtract()
(true, true)
```


#####William Kahan on QNaNs

NaNs propagate through most computations. Consequently they do get used. ... they are needed only for computation, with temporal sequencing that can be hard to revise, harder to reverse. NaNs must conform to mathematically consistent rules that were deduced, not invented arbitrarily ...

NaNs [give software the opportunity] ( especially when searching ) to follow an unexceptional path ( no need for exotic control structures ) to a point where an exceptional event can be appraised ... when additional evidence may have accrued ...  NaNs [have] a field of bits into which software can record, say, how and/or where the NaN came into existence. That [can be] extremely helpful [in] “Retrospective Diagnosis”

-- IEEE754 Lecture Notes (highly redacted)

References:
[William Kahan's IEEE754 Lecture Notes](http://www.eecs.berkeley.edu/~wkahan/ieee754status/IEEE754.PDF)
["An Elegant Pairing Function" by Matthew Szudzik](http://szudzik.com/ElegantPairing.pdf)


<!---
[![Build Status](https://travis-ci.org/JeffreySarnoff/QNaN.jl.svg?branch=master)](https://travis-ci.org/JeffreySarnoff/QNaN.jl)
--->
