public final class DataLoader<Key: Hashable, Value> {
  public typealias BatchLoad = ([Key]) -> Promise<[Value]>
  typealias Load = (key: Key, fulfill: (Value) -> Void, reject: (Error) -> Void)
  
  private let queue: DispatchQueue
  
  private var batchLoad: BatchLoad
  
  private var cache: [Key: Promise<Value>] = [:]
  private var loads: [Load] = []
  
  public init(_ batchLoad: @escaping BatchLoad) {
    queue = DispatchQueue(label: "com.apollographql.DataLoader")
    
    self.batchLoad = batchLoad
  }
  
  subscript(key: Key) -> Promise<Value> {
    if let promise = cache[key] {
      return promise
    }
    
    let promise = Promise<Value> { fulfill, reject in
      enqueue(load: (key, fulfill, reject))
    }
    
    cache[key] = promise
    
    return promise
  }
  
  private func enqueue(load: Load) {
    queue.async {
      self.loads.append(load)
    }
  }
  
  func dispatch() {
    queue.async {
      let loads = self.loads
      
      if loads.isEmpty { return }
        
      self.loads = []
      
      let keys = loads.map { $0.key }
      
      self.batchLoad(keys).andThen { values in
        // TODO: Using zip would have been the nicest solution, but it currently leads to a compiler crash. 
        // This seems to have been fixed in Xcode 8.3, so we can replace it once that is out.
        // for (load, value) in zip(loads, values) {
        for (index, value) in values.enumerated() {
          let load = loads[index]
          load.fulfill(value)
        }
      }
    }
  }
}
