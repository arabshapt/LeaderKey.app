import { Detail, List } from "@raycast/api";
import type { FlatIndexRecord } from "@leaderkey/config-core";

import { buildRecordDetailPresentation, type DetailMetadataRow } from "./detail-presentation.js";

interface MetadataComponents {
  Label: any;
  Root: any;
  Separator: any;
}

function renderMetadata(rows: DetailMetadataRow[], components: MetadataComponents) {
  const Root = components.Root;
  const Label = components.Label;
  const Separator = components.Separator;

  return (
    <Root>
      {rows.flatMap((row, index) => [
        <Label key={`label-${row.title}-${index}`} title={row.title} text={row.text} />,
        index < rows.length - 1 ? <Separator key={`separator-${index}`} /> : null,
      ])}
    </Root>
  );
}

export function recordListItemDetail(record: FlatIndexRecord) {
  const presentation = buildRecordDetailPresentation(record);

  return (
    <List.Item.Detail
      markdown={presentation.markdown}
      metadata={renderMetadata(presentation.metadata, {
        Label: List.Item.Detail.Metadata.Label,
        Root: List.Item.Detail.Metadata,
        Separator: List.Item.Detail.Metadata.Separator,
      })}
    />
  );
}

export function RecordDetailView(props: { record: FlatIndexRecord }) {
  const presentation = buildRecordDetailPresentation(props.record);

  return (
    <Detail
      markdown={presentation.markdown}
      metadata={renderMetadata(presentation.metadata, {
        Label: Detail.Metadata.Label,
        Root: Detail.Metadata,
        Separator: Detail.Metadata.Separator,
      })}
      navigationTitle={presentation.title}
    />
  );
}
