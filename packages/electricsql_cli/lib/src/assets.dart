import 'package:embed_annotation/embed_annotation.dart';

part 'assets.g.dart';

const _kRootAssetPath = '../../assets';

@EmbedStr('$_kRootAssetPath/docker/compose.yaml')
const kComposeYaml = _$kComposeYaml;

@EmbedStr('$_kRootAssetPath/docker/compose-base.yaml')
const kComposeBaseYaml = _$kComposeBaseYaml;

@EmbedStr('$_kRootAssetPath/docker/postgres.conf')
const kPostgresConf = _$kPostgresConf;
