library(validate)
library(data.table)
library(Rflow)
data(cars)
head(cars, 3)

dtRULES<-data.table( rule = c("speed >= 0"
, "dist >= 0"
, "speed/dist <= 1.5"
))
vRULES<-validate::validator(.data = dtRULES)
dtCHECK_RESULTS<-data.table(as.data.frame(out))
validate::satisfying(cars,vRULES)
validate::violating(cars,vRULES)

RDATA <- new.env()
RF<-new_rflow()
nodes_defs<-list(
"RDATA.MCARS" = list(
  r_expr = expression_r({
    cars
  }),
  validators = vRULES
),

"RDATA.MCARS2" = list(
  r_expr = expression_r({
    cars
  })
)

)
#,
#validators = vRULES
nodes_defs<-process_obj_defs(nodes_defs)

add_nodes(objs = nodes_defs, rflow = RF)

make(RF)

RF$RDATA.MCARS$validate()