## list packages that shall be automatically loaded
using DataFrames
## using Dates

module TimeData

## list packages whos namespace is used
using DataArrays
using DataFrames

using TimeSeries
## using Winston
## using Gadfly

importall Base
## importall Stats

export #
@roundDf,
@table,
AbstractTimedata,
AbstractTimenum,
AbstractTimematr,
aggrRets,
asArrayOfEqualDimensions,
complete_cases,
composeDataFrame,
cor,
core,
cov,
cumprod,
cumsum,
datsAsStrings,
datsAsFloats,
eachcol,
eachrow,
find,
floatcore,
floatDf,
geomMean,
get,
getDates,
hcat,
HTML,
idx,
impute!,
isaRowVector,
isequalElemwise,
issimilar,
joinSortedIdx_inner,
joinSortedIdx_left,
joinSortedIdx_outer,
joinSortedIdx_right,
mean,
minimum,
movAvg,
narm,
plot,
prod,
readTimedata,
resample,
round,
rowmeans,
rowprods,
rowstds,
rowsums,
setDfRow!,
setNA!,
showEntries,
std,
str,
sum,
testcase,
Timedata,
Timematr,
Timenum,
vcat,
writedlm,
writeTimedata

include("constraints.jl")
include("abstractTypes.jl")
include("timedata_type.jl")
include("timenum.jl")
include("timematr.jl")
include("constructors.jl")
include("getindex.jl")
include("setindex.jl")
include("display.jl")
include("abstractFuncs.jl")
include("preservingFuncs.jl")
include("showEntries.jl")
include("operators.jl")
include("stats.jl")
include("io.jl")
include("join.jl")
## include("plotting.jl")
include("dataframe_extensions.jl")
include("iterators.jl")
include("convert.jl")
include("utils.jl")

end
