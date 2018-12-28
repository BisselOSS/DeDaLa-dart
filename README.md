# DeDaLa - Declarative Data Layer

DeDaLa is a library that helps you manage complex data layers that contains multiple asynchronous data sources such as caches, databases or network requests. 
DeDaLa abstracts this complexity and provides an api that lets you define data flows in a declarative way!


## Example
The following data layer returns a user object. 
The data layer should:
1. Read the cache
2. If the cache is empty &rarr; read the database
3. Request the latest data at the api if last request is older than 1 minute
4. Save fetched data in the database & cache

Possible example without DeDaLa:

```dart
  memoryCache.get(myUserId).flatMap<User>((user) {
    
    // cache is empty
    if (user == null) {
      
      // check if the database has something
      return database.getUser(myUserId).flatMap((user) {
        
        // database is empty or last request was more than 1 minute ago
        if (user == null || _isDataExpired(minutes: 1)) {
          
          // request data from the api
          return api.requestUser(myUserId).flatMap((user) {
            
            // insert the data
            return memoryCache
                .set(myUserId, user)
                .flatMap((_) => database.insertUser(user));
          });
        } else {
          return Observable.just(user);
        }
      });
    } else {
      return Observable.just(user);
    }
  });
```

With DeDaLa:

```dart
  var userDeDaLa = DeDaLa<int, User>()
      .connectCache(source: memoryCache)
      .connect(
          readFrom: (id) => database.getUser(id),
          readPolicy: ReadPolicy.IfDownstreamEmpty(),
          insertTo: (int id, User user) => database.insertUser(user))
      .connect(
          readFrom: (id) => api.requestUser(id),
          readPolicy: ReadPolicy.Gated(duration: Duration(minutes: 1)));

  userDeDaLa.get(myUserId).listen((user) {
    // handle result
  });
```


----------

TODO:
- Principles
- Cache interface & Default cache implementation
- ReadPolicy
- InsertPolicy
- Custom Policies
- Recommend compile safety flag
- add roadmap with new features such as exception handling, file caching