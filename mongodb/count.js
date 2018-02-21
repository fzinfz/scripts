db.getCollection('view_pre').find({price_diff:{$ne:null}, tags_cmp:true}).count()

db.getCollection('view_pre').find({price_diff:{$ne:null}, tags_cmp:false}).count()

db.getCollection('tgt').find({}).count()

db.getCollection('tgt').find({created: /2016-03-2.*/}).count()

db.getCollection('pre').find( ).count()
db.getCollection('pre').find(  { iid: { $ne: null } }).count()

db.getCollection('src').find(  { tags: { $ne: null } }).count()
db.getCollection('pre').find(  { tags: { $ne: null } }).count()