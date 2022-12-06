// Copyright 2018-2019, Ralf Ebert
// License     https://opensource.org/licenses/MIT
// License     https://creativecommons.org/publicdomain/zero/1.0/
// Source      https://www.ralfebert.de/ios-examples/uikit/uitableviewcontroller/grouping-sections/

struct GroupedSection<SectionItem: Hashable, RowItem> {

    var sectionItem: SectionItem
    var rows: [RowItem]

    static func updateData(rows: [RowItem],
                           by criteria: (RowItem) -> SectionItem)
    -> [GroupedSection<SectionItem, RowItem>] {
        let groups = Dictionary(grouping: rows, by: criteria)
        return groups.map(GroupedSection.init(sectionItem:rows:))
    }
}
