// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_table.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMessageTableCollection on Isar {
  IsarCollection<MessageTable> get messageTables => this.collection();
}

const MessageTableSchema = CollectionSchema(
  name: r'MessageTable',
  id: -1704420409176655310,
  properties: {
    r'chatRoomId': PropertySchema(
      id: 0,
      name: r'chatRoomId',
      type: IsarType.long,
    ),
    r'from_': PropertySchema(id: 1, name: r'from_', type: IsarType.long),
    r'isSeen': PropertySchema(id: 2, name: r'isSeen', type: IsarType.bool),
    r'isSent': PropertySchema(id: 3, name: r'isSent', type: IsarType.bool),
    r'mediaJson': PropertySchema(
      id: 4,
      name: r'mediaJson',
      type: IsarType.string,
    ),
    r'message': PropertySchema(id: 5, name: r'message', type: IsarType.string),
    r'messageID': PropertySchema(
      id: 6,
      name: r'messageID',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 7,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'to': PropertySchema(id: 8, name: r'to', type: IsarType.long),
  },
  estimateSize: _messageTableEstimateSize,
  serialize: _messageTableSerialize,
  deserialize: _messageTableDeserialize,
  deserializeProp: _messageTableDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _messageTableGetId,
  getLinks: _messageTableGetLinks,
  attach: _messageTableAttach,
  version: '3.1.0+1',
);

int _messageTableEstimateSize(
  MessageTable object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.mediaJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.message.length * 3;
  bytesCount += 3 + object.messageID.length * 3;
  return bytesCount;
}

void _messageTableSerialize(
  MessageTable object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.chatRoomId);
  writer.writeLong(offsets[1], object.from_);
  writer.writeBool(offsets[2], object.isSeen);
  writer.writeBool(offsets[3], object.isSent);
  writer.writeString(offsets[4], object.mediaJson);
  writer.writeString(offsets[5], object.message);
  writer.writeString(offsets[6], object.messageID);
  writer.writeDateTime(offsets[7], object.timestamp);
  writer.writeLong(offsets[8], object.to);
}

MessageTable _messageTableDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MessageTable();
  object.chatRoomId = reader.readLong(offsets[0]);
  object.from_ = reader.readLong(offsets[1]);
  object.id = id;
  object.isSeen = reader.readBool(offsets[2]);
  object.isSent = reader.readBool(offsets[3]);
  object.mediaJson = reader.readStringOrNull(offsets[4]);
  object.message = reader.readString(offsets[5]);
  object.messageID = reader.readString(offsets[6]);
  object.timestamp = reader.readDateTime(offsets[7]);
  object.to = reader.readLong(offsets[8]);
  return object;
}

P _messageTableDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _messageTableGetId(MessageTable object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _messageTableGetLinks(MessageTable object) {
  return [];
}

void _messageTableAttach(
  IsarCollection<dynamic> col,
  Id id,
  MessageTable object,
) {
  object.id = id;
}

extension MessageTableQueryWhereSort
    on QueryBuilder<MessageTable, MessageTable, QWhere> {
  QueryBuilder<MessageTable, MessageTable, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MessageTableQueryWhere
    on QueryBuilder<MessageTable, MessageTable, QWhereClause> {
  QueryBuilder<MessageTable, MessageTable, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<MessageTable, MessageTable, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterWhereClause> idBetween(
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

extension MessageTableQueryFilter
    on QueryBuilder<MessageTable, MessageTable, QFilterCondition> {
  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  chatRoomIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chatRoomId', value: value),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  chatRoomIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'chatRoomId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  chatRoomIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'chatRoomId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  chatRoomIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'chatRoomId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> from_EqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'from_', value: value),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  from_GreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'from_',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> from_LessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'from_',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> from_Between(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'from_',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> isSeenEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSeen', value: value),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> isSentEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSent', value: value),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mediaJson'),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mediaJson'),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mediaJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mediaJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mediaJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mediaJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mediaJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mediaJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mediaJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mediaJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediaJson', value: ''),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  mediaJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mediaJson', value: ''),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'message', value: ''),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'message', value: ''),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
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

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  messageIDIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'messageID', value: ''),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  messageIDIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'messageID', value: ''),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> toEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'to', value: value),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> toGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'to',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> toLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'to',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterFilterCondition> toBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'to',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MessageTableQueryObject
    on QueryBuilder<MessageTable, MessageTable, QFilterCondition> {}

extension MessageTableQueryLinks
    on QueryBuilder<MessageTable, MessageTable, QFilterCondition> {}

extension MessageTableQuerySortBy
    on QueryBuilder<MessageTable, MessageTable, QSortBy> {
  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByChatRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomId', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy>
  sortByChatRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomId', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByFrom_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from_', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByFrom_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from_', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByIsSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSeen', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByIsSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSeen', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByIsSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSent', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByIsSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSent', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByMediaJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaJson', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByMediaJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaJson', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByMessageID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageID', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByMessageIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageID', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> sortByToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.desc);
    });
  }
}

extension MessageTableQuerySortThenBy
    on QueryBuilder<MessageTable, MessageTable, QSortThenBy> {
  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByChatRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomId', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy>
  thenByChatRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomId', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByFrom_() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from_', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByFrom_Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from_', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByIsSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSeen', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByIsSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSeen', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByIsSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSent', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByIsSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSent', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByMediaJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaJson', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByMediaJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaJson', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByMessageID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageID', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByMessageIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageID', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.asc);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QAfterSortBy> thenByToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.desc);
    });
  }
}

extension MessageTableQueryWhereDistinct
    on QueryBuilder<MessageTable, MessageTable, QDistinct> {
  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByChatRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chatRoomId');
    });
  }

  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByFrom_() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'from_');
    });
  }

  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByIsSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSeen');
    });
  }

  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByIsSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSent');
    });
  }

  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByMediaJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByMessage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'message', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByMessageID({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageID', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<MessageTable, MessageTable, QDistinct> distinctByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'to');
    });
  }
}

extension MessageTableQueryProperty
    on QueryBuilder<MessageTable, MessageTable, QQueryProperty> {
  QueryBuilder<MessageTable, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MessageTable, int, QQueryOperations> chatRoomIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chatRoomId');
    });
  }

  QueryBuilder<MessageTable, int, QQueryOperations> from_Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'from_');
    });
  }

  QueryBuilder<MessageTable, bool, QQueryOperations> isSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSeen');
    });
  }

  QueryBuilder<MessageTable, bool, QQueryOperations> isSentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSent');
    });
  }

  QueryBuilder<MessageTable, String?, QQueryOperations> mediaJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaJson');
    });
  }

  QueryBuilder<MessageTable, String, QQueryOperations> messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'message');
    });
  }

  QueryBuilder<MessageTable, String, QQueryOperations> messageIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageID');
    });
  }

  QueryBuilder<MessageTable, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<MessageTable, int, QQueryOperations> toProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'to');
    });
  }
}
