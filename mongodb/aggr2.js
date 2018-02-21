db.getCollection('pre').aggregate([    
{ $lookup: { localField: "alias", from: "src",foreignField: "alias",as: "src" }} 
,{ $lookup: { localField: "iid", from: "tgt",foreignField: "num_iid",as: "tgt" }} 
,{ $unwind: {path: "$tgt", preserveNullAndEmptyArrays: true}}  
,{ $unwind: {path: "$src", preserveNullAndEmptyArrays: true}}  
,{ $project: { _id: 0, tgt_id: 1,  alias: 1 ,alias_new: "$tgt.alias",tag_ids: 1, iid: 1, 'imgs#src':1, 'imgs#tgt':1, 'imgs#diff':1
    , created: "$tgt.created", src_price : '$src.price', tgt_price : '$tgt.price'   
    , src_skus: '$src.skus_with_json', tgt_skus : '$tgt.skus'
    } } 
,{ $out : "view_src_tgt" }
 ])

