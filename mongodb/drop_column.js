db.getCollection('src').update({},
{$unset: {cate_src: ""} },
{multi: true }
)