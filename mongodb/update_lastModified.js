db.getCollection('src').update({lastModified: null },
    {$currentDate: { lastModified : true } },
    {multi:true}
)
