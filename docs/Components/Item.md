# Item

More information available at: [Menu](https://shunnedreality.github.io/material-roblox/components/menu).

!!! note

    While `Item` components can be used with `Menu`, unlike `NavigationTab` and `TabItem`, `Item` does not necessarily need to be placed inside of a Menu.

## API

```typescript
Item(
    scope: Fusion.Scope,
    props: {
        icon: string?,
        label: string,
        trailing: string?,
        onClick: () -> ()?
    }
)
```