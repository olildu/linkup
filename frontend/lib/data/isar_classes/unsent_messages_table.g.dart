// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsent_messages_table.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUnsentMessagesTableCollection on Isar {
  IsarCollection<UnsentMessagesTable> get unsentMessagesTables =>
      this.collection();
}

const UnsentMessagesTableSchema = CollectionSchema(
  name: r'UnsentMessagesTable',
  id: 566467332286484674,
  properties: {
    r'chatRoomID': PropertySchema(
      id: 0,
      name: r'chatRoomID',
      type: IsarType.long,
    ),
    r'message': PropertySchema(id: 1, name: r'message', type: IsarType.string),
    r'messageID': PropertySchema(
      id: 2,
      name: r'messageID',
      type: IsarType.string,
    ),
  },
  estimateSize: _unsentMessagesTableEstimateSize,
  serialize: _unsentMessagesTableSerialize,
  deserialize: _unsentMessagesTableDeserialize,
  deserializeProp: _unsentMessagesTableDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _unsentMessagesTableGetId,
  getLinks: _unsentMessagesTableGetLinks,
  attach: _unsentMessagesTableAttach,
  version: '3.1.0+1',
);

int _unsentMessagesTableEstimateSize(
  UnsentMessagesTable object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.message.length * 3;
  bytesCount += 3 + object.messageID.length * 3;
  return bytesCount;
}

void _unsentMessagesTableSerialize(
  UnsentMessagesTable object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.chatRoomID);
  writer.writeString(offsets[1], object.message);
  writer.writeString(offsets[2], object.messageID);
}

UnsentMessagesTable _unsentMessagesTableDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UnsentMessagesTable();
  object.chatRoomID = reader.readLong(offsets[0]);
  object.id = id;
  object.message = reader.readString(offsets[1]);
  object.messageID = reader.readString(offsets[2]);
  return object;
}

P _unsentMessagesTableDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _unsentMessagesTableGetId(UnsentMessagesTable object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _unsentMessagesTableGetLinks(
  UnsentMessagesTable object,
) {
  return [];
}

void _unsentMessagesTableAttach(
  IsarCollection<dynamic> col,
  Id id,
  UnsentMessagesTable object,
) {
  object.id = id;
}

extension UnsentMessagesTableQueryWhereSort
    on QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QWhere> {
  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UnsentMessagesTableQueryWhere
    on QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QWhereClause> {
  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UnsentMessagesTableQueryFilter
    on
        QueryBuilder<
          UnsentMessagesTable,
          UnsentMessagesTable,
          QFilterCondition
        > {
  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  chatRoomIDEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chatRoomID', value: value),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  chatRoomIDGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'chatRoomID',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  chatRoomIDLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'chatRoomID',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  chatRoomIDBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'chatRoomID',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'message',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'message',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'message',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'message', value: ''),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'message', value: ''),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'messageID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'messageID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'messageID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'messageID',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'messageID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'messageID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'messageID',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'messageID',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'messageID', value: ''),
      );
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterFilterCondition>
  messageIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'messageID', value: ''),
      );
    });
  }
}

extension UnsentMessagesTableQueryObject
    on
        QueryBuilder<
          UnsentMessagesTable,
          UnsentMessagesTable,
          QFilterCondition
        > {}

extension UnsentMessagesTableQueryLinks
    on
        QueryBuilder<
          UnsentMessagesTable,
          UnsentMessagesTable,
          QFilterCondition
        > {}

extension UnsentMessagesTableQuerySortBy
    on QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QSortBy> {
  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  sortByChatRoomID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomID', Sort.asc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  sortByChatRoomIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomID', Sort.desc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  sortByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  sortByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  sortByMessageID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageID', Sort.asc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  sortByMessageIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageID', Sort.desc);
    });
  }
}

extension UnsentMessagesTableQuerySortThenBy
    on QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QSortThenBy> {
  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  thenByChatRoomID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomID', Sort.asc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  thenByChatRoomIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomID', Sort.desc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  thenByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  thenByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  thenByMessageID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageID', Sort.asc);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QAfterSortBy>
  thenByMessageIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageID', Sort.desc);
    });
  }
}

extension UnsentMessagesTableQueryWhereDistinct
    on QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QDistinct> {
  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QDistinct>
  distinctByChatRoomID() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chatRoomID');
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QDistinct>
  distinctByMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'message', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QDistinct>
  distinctByMessageID({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageID', caseSensitive: caseSensitive);
    });
  }
}

extension UnsentMessagesTableQueryProperty
    on QueryBuilder<UnsentMessagesTable, UnsentMessagesTable, QQueryProperty> {
  QueryBuilder<UnsentMessagesTable, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UnsentMessagesTable, int, QQueryOperations>
  chatRoomIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chatRoomID');
    });
  }

  QueryBuilder<UnsentMessagesTable, String, QQueryOperations>
  messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'message');
    });
  }

  QueryBuilder<UnsentMessagesTable, String, QQueryOperations>
  messageIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageID');
    });
  }
}
