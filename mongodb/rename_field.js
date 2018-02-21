db.getCollection('src').update({}, 
{ $rename : { 'name.additional' : 'name.last' } }, 
{ multi: true } )