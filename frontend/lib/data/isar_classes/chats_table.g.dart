// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_table.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChatsTableCollection on Isar {
  IsarCollection<ChatsTable> get chatsTables => this.collection();
}

const ChatsTableSchema = CollectionSchema(
  name: r'ChatsTable',
  id: 6464503489031371910,
  properties: {
    r'chatID': PropertySchema(id: 0, name: r'chatID', type: IsarType.long),
    r'chatRoomId': PropertySchema(
      id: 1,
      name: r'chatRoomId',
      type: IsarType.long,
    ),
    r'isDeleted': PropertySchema(
      id: 2,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'message': PropertySchema(id: 3, name: r'message', type: IsarType.string),
    r'profilePictureMetaDataJson': PropertySchema(
      id: 4,
      name: r'profilePictureMetaDataJson',
      type: IsarType.string,
    ),
    r'unseenCounter': PropertySchema(
      id: 5,
      name: r'unseenCounter',
      type: IsarType.long,
    ),
    r'username': PropertySchema(
      id: 6,
      name: r'username',
      type: IsarType.string,
    ),
  },
  estimateSize: _chatsTableEstimateSize,
  serialize: _chatsTableSerialize,
  deserialize: _chatsTableDeserialize,
  deserializeProp: _chatsTableDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _chatsTableGetId,
  getLinks: _chatsTableGetLinks,
  attach: _chatsTableAttach,
  version: '3.1.0+1',
);

int _chatsTableEstimateSize(
  ChatsTable object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.message;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.profilePictureMetaDataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.username.length * 3;
  return bytesCount;
}

void _chatsTableSerialize(
  ChatsTable object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.chatID);
  writer.writeLong(offsets[1], object.chatRoomId);
  writer.writeBool(offsets[2], object.isDeleted);
  writer.writeString(offsets[3], object.message);
  writer.writeString(offsets[4], object.profilePictureMetaDataJson);
  writer.writeLong(offsets[5], object.unseenCounter);
  writer.writeString(offsets[6], object.username);
}

ChatsTable _chatsTableDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChatsTable();
  object.chatID = reader.readLong(offsets[0]);
  object.chatRoomId = reader.readLong(offsets[1]);
  object.id = id;
  object.isDeleted = reader.readBool(offsets[2]);
  object.message = reader.readStringOrNull(offsets[3]);
  object.profilePictureMetaDataJson = reader.readStringOrNull(offsets[4]);
  object.unseenCounter = reader.readLong(offsets[5]);
  object.username = reader.readString(offsets[6]);
  return object;
}

P _chatsTableDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chatsTableGetId(ChatsTable object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chatsTableGetLinks(ChatsTable object) {
  return [];
}

void _chatsTableAttach(IsarCollection<dynamic> col, Id id, ChatsTable object) {
  object.id = id;
}

extension ChatsTableQueryWhereSort
    on QueryBuilder<ChatsTable, ChatsTable, QWhere> {
  QueryBuilder<ChatsTable, ChatsTable, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChatsTableQueryWhere
    on QueryBuilder<ChatsTable, ChatsTable, QWhereClause> {
  QueryBuilder<ChatsTable, ChatsTable, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterWhereClause> idBetween(
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

extension ChatsTableQueryFilter
    on QueryBuilder<ChatsTable, ChatsTable, QFilterCondition> {
  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> chatIDEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chatID', value: value),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> chatIDGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'chatID',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> chatIDLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'chatID',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> chatIDBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'chatID',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> chatRoomIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chatRoomId', value: value),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> chatRoomIdBetween(
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> isDeletedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDeleted', value: value),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'message'),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  messageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'message'),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  messageGreaterThan(
    String? value, {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageLessThan(
    String? value, {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'message', value: ''),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'message', value: ''),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'profilePictureMetaDataJson'),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'profilePictureMetaDataJson',
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'profilePictureMetaDataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'profilePictureMetaDataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'profilePictureMetaDataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'profilePictureMetaDataJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'profilePictureMetaDataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'profilePictureMetaDataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'profilePictureMetaDataJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'profilePictureMetaDataJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'profilePictureMetaDataJson',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  profilePictureMetaDataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'profilePictureMetaDataJson',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  unseenCounterEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unseenCounter', value: value),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  unseenCounterGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unseenCounter',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  unseenCounterLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unseenCounter',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  unseenCounterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unseenCounter',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> usernameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  usernameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> usernameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> usernameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'username',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  usernameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> usernameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> usernameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'username',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition> usernameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'username',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  usernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'username', value: ''),
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterFilterCondition>
  usernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'username', value: ''),
      );
    });
  }
}

extension ChatsTableQueryObject
    on QueryBuilder<ChatsTable, ChatsTable, QFilterCondition> {}

extension ChatsTableQueryLinks
    on QueryBuilder<ChatsTable, ChatsTable, QFilterCondition> {}

extension ChatsTableQuerySortBy
    on QueryBuilder<ChatsTable, ChatsTable, QSortBy> {
  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByChatID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatID', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByChatIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatID', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByChatRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomId', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByChatRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomId', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy>
  sortByProfilePictureMetaDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profilePictureMetaDataJson', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy>
  sortByProfilePictureMetaDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profilePictureMetaDataJson', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByUnseenCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unseenCounter', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByUnseenCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unseenCounter', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> sortByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension ChatsTableQuerySortThenBy
    on QueryBuilder<ChatsTable, ChatsTable, QSortThenBy> {
  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByChatID() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatID', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByChatIDDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatID', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByChatRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomId', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByChatRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatRoomId', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy>
  thenByProfilePictureMetaDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profilePictureMetaDataJson', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy>
  thenByProfilePictureMetaDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profilePictureMetaDataJson', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByUnseenCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unseenCounter', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByUnseenCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unseenCounter', Sort.desc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QAfterSortBy> thenByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension ChatsTableQueryWhereDistinct
    on QueryBuilder<ChatsTable, ChatsTable, QDistinct> {
  QueryBuilder<ChatsTable, ChatsTable, QDistinct> distinctByChatID() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chatID');
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QDistinct> distinctByChatRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chatRoomId');
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QDistinct> distinctByMessage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'message', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QDistinct>
  distinctByProfilePictureMetaDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'profilePictureMetaDataJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QDistinct> distinctByUnseenCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unseenCounter');
    });
  }

  QueryBuilder<ChatsTable, ChatsTable, QDistinct> distinctByUsername({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'username', caseSensitive: caseSensitive);
    });
  }
}

extension ChatsTableQueryProperty
    on QueryBuilder<ChatsTable, ChatsTable, QQueryProperty> {
  QueryBuilder<ChatsTable, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChatsTable, int, QQueryOperations> chatIDProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chatID');
    });
  }

  QueryBuilder<ChatsTable, int, QQueryOperations> chatRoomIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chatRoomId');
    });
  }

  QueryBuilder<ChatsTable, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<ChatsTable, String?, QQueryOperations> messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'message');
    });
  }

  QueryBuilder<ChatsTable, String?, QQueryOperations>
  profilePictureMetaDataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profilePictureMetaDataJson');
    });
  }

  QueryBuilder<ChatsTable, int, QQueryOperations> unseenCounterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unseenCounter');
    });
  }

  QueryBuilder<ChatsTable, String, QQueryOperations> usernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'username');
    });
  }
}
