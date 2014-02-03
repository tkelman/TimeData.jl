<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. TimeData types</a></li>
<li><a href="#sec-2">2. Constructors</a></li>
<li><a href="#sec-3">3. Indexing</a></li>
<li><a href="#sec-4">4. Read, write, io</a></li>
<li><a href="#sec-5">5. Functions and operators inherited from DataFrames</a></li>
<li><a href="#sec-6">6. Additional functions</a></li>
<li><a href="#sec-7">7. Acknowledgement</a></li>
</ul>
</div>
</div>

# TimeData types

All types introduced are subtypes of abstract type `AbstractTimedata`
and have two fields, separating time information from observations:

-   **vals:** a `DataFrame`

-   **idx:** an `Array{T, 1}`, consisting of type `Integer`, or type
             `Date` or `DateTime` from package `Datetime`


However, accessing these fields directly is considered poor style, as
one could circumvent any constraints on the individual fields this
way! Hence, only reference the fields directly if you really know what
you are doing.

Given these commonalities of all `TimeData` types, there exist several
distinct types that implement different constraints on the
observations. Sorted from most general to most specific case, the
following types are introduced:

-   **`Timedata`:** no further restrictions on observations

-   **`Timenum`:** observations may consist of numeric values or missing
    values only

-   **`Timematr`:** observations must be numeric values only

-   **`Timecop`:** observations must be numeric values between 0 and 1
    only

Given that these constraints are fulfilled, one is able to define and
use more specific functions matching the data characteristics more
closely. For example, `Timematr` instances can directly make use of
fast and numerically optimized methods using `Array{Float64, 2}` under
the hood. Hence, it is important that these constraints are reliably
fulfilled. They are guaranteed as they are hard-coded into variables
at creation through the individual constructors. And, by now, no
further `setindex` methods exist that would allow data manipulation.

# Constructors

For each type, variables can be created by directly handing over
observations as `DataFrame` and time information as `Array` to the
inner constructor.

    using TimeData
    using Datetime

    vals = rand(30, 4)
    dats = Date{ISOCalendar}[date(2013, 7, ii) for ii=1:30]
    nams = ["A", "B", "C", "D"]
    valsDf = DataFrame(vals, nams)
    
    tm = Timematr(valsDf, dats)

Besides, there also exist several outer constructors for each type,
allowing more convenient creation. In particular, if observations do
not entail any `NAs`, there is no need to wrap them up into
`DataFrames` previously, but `TimeData` objects can simply be created
from `Arrays`. Also, there might be situations where variable names
and / or dates are missing. For these cases, there exist more
convenient outer constructors, too, which generally follow the
convention that dates do never precede variable names as arguments.

    tm = Timematr(vals, nams, dats)
    tm = Timematr(vals, nams)
    tm = Timematr(vals, dats)
    tm = Timematr(vals)

# Indexing

The idea of `getindex` is to stick with the behavior of `DataFrames`
as far as possible for the basics, while extending it to allow
indexing of rows by dates. Hence, indexing `TimeData` types should
hopefully fit seamlessly into behavior familiar from other important
types, with only intuitive extensions. However, it is important to
note that indexing deviates from `DataFrame` behavior in one aspect:
`getindex` will NEVER change the type of the variable! If you call it
on a `Timematr` variable, it will also return a `Timematr` variable,
and if you call it on type `Timenum` it will return `Timenum` as well.
Although this seems to be quite logically, this behavior does deviate
from `DataFrame` behavior in such that, for example, `DataFrames`
return `DataArray` for single columns.

    typeof(valsDf[:, 1])
    typeof(tm[:, 1])
    
    typeof(valsDf[1, 1])
    typeof(tm[1, 1])
    
    ## empty instance
    typeof(tm[4:3, 5:4])

This will print:

    DataArray{Float64,1} (constructor with 1 method)
    Timematr{Date{ISOCalendar}} (constructor with 1 method)
    
    Float64
    Timematr{Date{ISOCalendar}} (constructor with 1 method)
    
    
    Timematr{Date{ISOCalendar}} (constructor with 1 method)


Possible ways of indexing are:

    ## indexing by numeric indices
    tmp = tm[2:4]
    tmp = tm[3:5, 1:2]
    tmp = tm[5, :]
    tmp = tm[2]
    tmp = tm[5:8, 2]
    tmp = tm[5, 3]
    
    ## indexing with column names as symbols
    tmp = tm[:A]
    tmp = tm[5, [:A, :B]]
    
    ## logical indexing
    logicCol = [true, false, true, false]
    logicRow = repmat([true, false, true], 10, 1)[:]
    tmp = tm[logicCol]
    tmp = tm[logicRow, logicCol]
    tmp = tm[logicRow, :]
    
    ## logically indexing rows directly from expression
    ex = :(A .> 0.5)
    tmp = tm[ex, :]
    
    ## indexing by date
    tmp = tm[date(2013, 07, 04)]
    
    datesToFind = Date{ISOCalendar}[date(2013, 07, ii) for ii=12:18]
    tmp = tm[datesToFind]
    tm[date(2013,07,03):date(2013,07,12)]
    tm[date(2013,07,03):date(2013,07,12), :D]
    tm[date(2013,07,03):date(2013,07,12),
                 [true, false, false, true]]

# Read, write, io

Data can easily be imported from csv-files using function
`readTimedata`. Under the hood, the function makes use of `readtable`
from the `DataFrames` package. Additionally, columns are parsed for
dates similar to function `readtime` from package `TimeSeries`. The
first column matching the regexp for dates will be chosen as time
identifier. 

    tm = readTimedata("data/logRet.csv")

After loading the data, Julia will call the standard `display` method
to show information about the data:

    
    type: Timematr{Date{ISOCalendar}}
    dimensions: (333,348)
    333x6 DataFrame:
                   dates      MMM      ABT      ACE      ACT     ADBE
    [1,]      2012-01-03  2.12505  0.88718  0.29744  0.47946   1.0556
    [2,]      2012-01-04  0.82264 -0.38476 -0.95495 -0.52919 -1.02024
    [3,]      2012-01-05 -0.44787 -0.23157  0.28445  2.74752  0.70472
    [4,]      2012-01-06 -0.51253 -0.93168  0.23891  1.94894  0.83917
    [5,]      2012-01-09  0.58732      0.0  0.46128  0.28436 -0.66376
    [6,]      2012-01-10  0.52193  0.46693  1.31261  1.85986  2.32125
    [7,]      2012-01-11 -0.63413 -0.38895 -1.52066 -3.06604  0.41012
    [8,]      2012-01-12  0.60934 -0.46875  0.50453 -0.93039 -0.30743
    [9,]      2012-01-13 -0.80912  0.50771 -0.47478  0.25752 -0.89348
    [10,]     2012-01-17  0.74711  0.50515    0.297 -7.04176  1.30317
    [11,]     2012-01-18  0.98754  -0.6611  0.17778 -0.06901  1.82314
    [12,]     2012-01-19  0.85617  0.15595   1.1918  3.92605  1.16416
    [13,]     2012-01-20 -0.17065  0.58264  2.42751 -3.58146  0.85611
    [14,]     2012-01-23 -0.04881 -0.07749 -1.20639 -1.61252 -0.88919
    [15,]     2012-01-24  0.37766  0.46404 -0.98738 -2.33432  2.35382
    [16,]     2012-01-25  0.63031 -1.35951  0.81384  3.03107  1.25222
    [17,]     2012-01-26  1.26075  -0.6277  -0.5952  1.78914 -0.51184
    [18,]     2012-01-27 -0.13134   0.2751  -2.5512  1.84142 -0.41781
    [19,]     2012-01-30 -0.14347 -1.02565 -0.68945  0.26747 -0.16116
    [20,]     2012-01-31 -0.72046 -0.59654  0.89834   -2.143 -0.16142
      :
    [314,]    2013-04-04  0.13388  0.88398  1.18103  0.59652  1.16029
    [315,]    2013-04-05 -0.03823 -0.91173 -0.09035  1.39877 -1.89525
    [316,]    2013-04-08 -0.02868   0.6639  1.19062  1.19664   0.9407
    [317,]    2013-04-09  0.19108  0.27533  0.54563 -0.66303  0.86403
    [318,]    2013-04-10  1.62836  1.20253  0.44321 -0.51303  1.19277
    [319,]    2013-04-11  0.51515  0.83864  1.06671  0.56419  1.13448
    [320,]    2013-04-12 -0.52454 -0.37787  0.08747 -0.44082 -0.39894
    [321,]    2013-04-15 -1.80048  -2.7414 -3.52592 -1.34466 -0.95951
    [322,]    2013-04-16  0.37223  0.74762   1.1929   0.9741  1.51316
    [323,]    2013-04-17 -0.63074  2.39859 -1.07975  0.78069 -0.84276
    [324,]    2013-04-18 -0.48049 -1.08314 -0.63528  -1.0802 -0.98479
    [325,]    2013-04-19  0.69118  0.86745  0.77089  1.84469   0.6278
    [326,]    2013-04-22  0.08606 -0.84023  0.27067 -0.64178 -0.47048
    [327,]    2013-04-23  1.48952  0.86721   0.8188  0.93582  0.76063
    [328,]    2013-04-24    0.451  -1.8794 -0.51518 -0.49734 -0.44673
    [329,]    2013-04-25 -2.81414 -0.08252 -0.04492  0.61876  0.84708
    [330,]    2013-04-26 -1.04683 -0.08259 -0.63106  2.05182 -0.31125
    [331,]    2013-04-29  0.03897  0.74085 -0.02261  4.49427  0.33344
    [332,]    2013-04-30  0.84381  0.51807  0.24845  0.14197  0.04438
    [333,]    2013-05-01 -0.14498 -0.08162 -0.94057 -1.27548 -0.82415

As one can see, the `display` method will show the type of the
variable, together with its dimensions and a snippet into the first
values. Note that the number of columns does not entail the dates
column, but does only count the columns of the remaining variables.
Inherently, `display` makes use of the method that is implemented for
`DataFrames`, which is the reason for the somewhat misleading output
line `333x6 DataFrame:`. An issue that still remains to be fixed. In
contrast to the standard output of `DataFrames`, there is no explicit
information for the rest of the columns. 

An even more elaborate way of looking at the data contained in a
`TimeData` type is function `str` (following the name used in R),
which will print:

    str(tm)

    
    type: Timematr{Date{ISOCalendar}}
    :vals         DataFrame
    :idx          Array{Date{ISOCalendar},1}
    
    dimensions: (333,348)
    
    -------------------------------------------
    From: 2012-01-03, To: 2013-05-01
    -------------------------------------------
    
    333x6 DataFrame:
                   dates      MMM      ABT      ACE      ACT     ADBE
    [1,]      2012-01-03  2.12505  0.88718  0.29744  0.47946   1.0556
    [2,]      2012-01-04  0.82264 -0.38476 -0.95495 -0.52919 -1.02024
    [3,]      2012-01-05 -0.44787 -0.23157  0.28445  2.74752  0.70472
    [4,]      2012-01-06 -0.51253 -0.93168  0.23891  1.94894  0.83917
    [5,]      2012-01-09  0.58732      0.0  0.46128  0.28436 -0.66376
    [6,]      2012-01-10  0.52193  0.46693  1.31261  1.85986  2.32125
    [7,]      2012-01-11 -0.63413 -0.38895 -1.52066 -3.06604  0.41012
    [8,]      2012-01-12  0.60934 -0.46875  0.50453 -0.93039 -0.30743
    [9,]      2012-01-13 -0.80912  0.50771 -0.47478  0.25752 -0.89348
    [10,]     2012-01-17  0.74711  0.50515    0.297 -7.04176  1.30317
    [11,]     2012-01-18  0.98754  -0.6611  0.17778 -0.06901  1.82314
    [12,]     2012-01-19  0.85617  0.15595   1.1918  3.92605  1.16416
    [13,]     2012-01-20 -0.17065  0.58264  2.42751 -3.58146  0.85611
    [14,]     2012-01-23 -0.04881 -0.07749 -1.20639 -1.61252 -0.88919
    [15,]     2012-01-24  0.37766  0.46404 -0.98738 -2.33432  2.35382
    [16,]     2012-01-25  0.63031 -1.35951  0.81384  3.03107  1.25222
    [17,]     2012-01-26  1.26075  -0.6277  -0.5952  1.78914 -0.51184
    [18,]     2012-01-27 -0.13134   0.2751  -2.5512  1.84142 -0.41781
    [19,]     2012-01-30 -0.14347 -1.02565 -0.68945  0.26747 -0.16116
    [20,]     2012-01-31 -0.72046 -0.59654  0.89834   -2.143 -0.16142
      :
    [314,]    2013-04-04  0.13388  0.88398  1.18103  0.59652  1.16029
    [315,]    2013-04-05 -0.03823 -0.91173 -0.09035  1.39877 -1.89525
    [316,]    2013-04-08 -0.02868   0.6639  1.19062  1.19664   0.9407
    [317,]    2013-04-09  0.19108  0.27533  0.54563 -0.66303  0.86403
    [318,]    2013-04-10  1.62836  1.20253  0.44321 -0.51303  1.19277
    [319,]    2013-04-11  0.51515  0.83864  1.06671  0.56419  1.13448
    [320,]    2013-04-12 -0.52454 -0.37787  0.08747 -0.44082 -0.39894
    [321,]    2013-04-15 -1.80048  -2.7414 -3.52592 -1.34466 -0.95951
    [322,]    2013-04-16  0.37223  0.74762   1.1929   0.9741  1.51316
    [323,]    2013-04-17 -0.63074  2.39859 -1.07975  0.78069 -0.84276
    [324,]    2013-04-18 -0.48049 -1.08314 -0.63528  -1.0802 -0.98479
    [325,]    2013-04-19  0.69118  0.86745  0.77089  1.84469   0.6278
    [326,]    2013-04-22  0.08606 -0.84023  0.27067 -0.64178 -0.47048
    [327,]    2013-04-23  1.48952  0.86721   0.8188  0.93582  0.76063
    [328,]    2013-04-24    0.451  -1.8794 -0.51518 -0.49734 -0.44673
    [329,]    2013-04-25 -2.81414 -0.08252 -0.04492  0.61876  0.84708
    [330,]    2013-04-26 -1.04683 -0.08259 -0.63106  2.05182 -0.31125
    [331,]    2013-04-29  0.03897  0.74085 -0.02261  4.49427  0.33344
    [332,]    2013-04-30  0.84381  0.51807  0.24845  0.14197  0.04438
    [333,]    2013-05-01 -0.14498 -0.08162 -0.94057 -1.27548 -0.82415

This will additionally show the names of the fields of any object, and
also explicitly display the time period of the data.

To save an object to disk, simply call function `writeTimedata`, which
internally uses `writetable` from the `DataFrame` package. In
accordance with `writetable`, the first argument is the filename as
string, while the second argument is the variable to be saved.

    writeTimedata("data/logRet2.csv", tm)

# Functions and operators inherited from DataFrames

Most of the standard functions and mathematical operators that are
defined for `DataFrames` are also implemented for `TimeData` types and
should behave as expected. Whenever possible, functions apply
elementwise to observations only, and you should get back the same
type that you did use to call the function. In case that this is not
possible, the type that you get back should be the natural first
choice. For example, elementwise comparisons should return a logical
value for each entry, which by definition could not be of type
`Timenum` where only numeric values are allowed. 

    typeof(tm + tm)
    typeof(tm .> 0.5)

    Timematr (constructor with 9 methods)
    Timedata (constructor with 9 methods)

The standard library for `TimeData` comprises all standard operators
and mathematical functions. As expected, these functions all apply
elementwise, and leave the time information untouched. Where
additional arguments are allowed for `DataFrames`, they are allowed
for `TimeData` types as well.

    tm[1:3, 1:3] .> 0.5
    exp(tm[1:3, 1:3])
    round(tm[1:3, 1:3], 2)

    
    type: Timedata
    dimensions: (3,3)
    3x4 DataFrame:
                 dates     A     B     C
    [1,]    2013-07-01 false false false
    [2,]    2013-07-02  true  true  true
    [3,]    2013-07-03  true false  true
    
    type: Timematr
    dimensions: (3,3)
    3x4 DataFrame:
                 dates       A       B       C
    [1,]    2013-07-01 1.59726   1.547 1.45007
    [2,]    2013-07-02 2.09634 2.42551 2.20417
    [3,]    2013-07-03 1.84294 1.50174 2.25843
    
    type: Timematr
    dimensions: (3,3)
    3x4 DataFrame:
                 dates    A    B    C
    [1,]    2013-07-01 0.47 0.44 0.37
    [2,]    2013-07-02 0.74 0.89 0.79
    [3,]    2013-07-03 0.61 0.41 0.81

A most likely not exhaustive list of basic functions is

    TimeDataFunctions = [:(+), :(.+), :(-), :(.-), :(*), :(.*), :(/),
                         :(./), :(.^),
                         :(div), :(mod), :(fld), :(rem),
                         :abs, :sign, :acos, :acosh, :asin, :asinh, :atan,
                         :atanh, :sin, :sinh, :cos, :cosh, :tan, :tanh,
                         :exp, :exp2, :expm1, :log, :log10, :log1p, :log2,
                         :exponent, :sqrt, :gamma, :lgamma, :digamma,
                         :erf, :erfc,
                         :(.==), :(.!=), :(.>), :(.>=), :(.<), :(.<=),
                         :(&), :(|), :($),
                         :round, :ceil, :floor, :trunc]

# Additional functions

Beside basic mathematical functions and operators, there are some
additional basic functions that are defined for each `TimeData` type.
For example, you can retrieve individual components of your variable
with the following functions:

-   **idx:** returns time information as `Array`

-   **names:** returns variable names as
                  `Array{Union(UTF8String,ASCIIString),1}`

-   **core:** implemented for subtypes of `AbstractTimematr`, it returns a
    matrix of numeric values

These functions shall help to inhibit direct access of `TimeData`
fields, which should be avoided.

Some further implemented functions are: 

-   `isequal`

-   `size`

-   `isna`

Furthermore, subtypes of type `AbstractTimematr` should already
provide functionality for basic statistical functions like `mean`,
`var` and `cov`.

# Acknowledgement

Of course, any package can only be as good as the individual parts
that it builds on. Accordingly, I'd like to thank all people that
were involved in the development of all the functions that were made
ready to use for me to build this package upon. In particular, I want
to thank the developers of

-   the **Julia language**, for their continuous and tremendous efforts
    during the creation of this free, fast and highly flexible
    programming language!

-   the **DataFrames** package, which definitely provides the best
    representation for general types of data in data analysis. It's a
    role model that every last bit of code of `TimeData` depends on, and
    the interface that every statistics package should use.

-   the **Datetime** package, which is a thoughtful implementation of
    dates, time and durations, and the backbone of all time components
    in `TimeData`.

-   the **TimeSeries** package, which follows a different approach to
    handling time series data by storing time information as a column of
    a DataFrame. Having a quite similar goal in mind, the package was a
    great inspiration for me, and occasionally I even could borrow parts
    of code from it (for example, function `readTimedata`).