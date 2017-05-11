import Vapor
import Leaf
import VaporLeaf

public final class Provider: Vapor.Provider {
  public init(config: Config) {}

  public func boot(_ drop: Droplet) {
    do {
        let stem = try drop.stem()
        let tags: [Tag] = [
            ErrorsForField(),
            IfFieldHasErrors(),
            LabelForField(),
            LoopErrorsForField(),
            ValueForField()
        ]
        tags.forEach(stem.register)
    } catch {}
  }

  public func beforeRun(_ drop: Droplet) {} // Remove when able
}
