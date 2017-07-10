import Vapor
import Leaf
import LeafProvider

public final class Provider: Vapor.Provider {
    public static let repositoryName = "Forms"

    public func boot(_ drop: Droplet) {
        guard let stem = drop.stem else { return }
        let tags: [Tag] = [
            ErrorsForField(),
            IfFieldHasErrors(),
            LabelForField(),
            LoopErrorsForField(),
            ValueForField()
        ]
        tags.forEach(stem.register)
    }
    
    // Remove when able
    public func beforeRun(_ drop: Droplet) {}
    public func boot(_ config: Config) throws {}
    public init(config: Config) {}
}
