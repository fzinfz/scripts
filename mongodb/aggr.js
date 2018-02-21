db.getCollection('pre').aggregate([    
{ $lookup: { localField: "alias", from: "src",foreignField: "alias",as: "src" }} 
,{ $unwind: {path: "$src", preserveNullAndEmptyArrays: true}}  
,{ $project: { _id: 0, tgt_id: 1,  alias: 1 ,

    created: "$src.
    ,price : 1, price_src : "$src.price" 
    ,price_diff: {$subtract: ['$price', '$src.price']}
    ,tags: 1, tags_src: "$src.tags", tags_cmp : {$eq: ['$tags',"$src.tags"]}
    } } 
,{ $out : "view_pre" }
 ])

db.getCollection('view_pre').find({price_diff:{$ne:null}, tags_cmp:false})


db.getCollection('pre').aggregate([    

{ $lookup: { localField: "alias", from: "src",foreignField: "alias",as: "src" }} 

,{ $unwind: {path: "$src", preserveNullAndEmptyArrays: true}}  

,{ $project: { _id: 0, tgt_id: 1,  alias: 1 ,

    created: "$src.

    ,price : 1, price_src : "$src.price" 

    ,price_diff: {$subtract: ['$price', '$src.price']}

    ,tags: 1, tags_src: "$src.tags", tags_cmp : {$eq: ['$tags',"$src.tags"]}

    } } 

,{ $out : "view_pre" }

 ])