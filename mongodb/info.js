db.getCollection('view_src_tgt').aggregate([

{ "$group": {"_id": {tgt_id: "$tgt_id", imgs_diff: '$imgs#diff' } , "count": {"$sum": 1} } }

,{ $unwind: {path: "$_id", preserveNullAndEmptyArrays: true}}  

,{ $project : { ID: '$_id.tgt_id', imgs_diff: '$_id.imgs_diff', qty: '$count'}  } 

])



db.getCollection('view_src_tgt').find({'imgs#diff':{$ne:0}}).sort({'imgs#diff':-1})