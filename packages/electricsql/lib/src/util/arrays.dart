/// Chunk an array based on the value returned by a mapping function.
///
/// Returns an iterable, that yields pairs with first value being the
/// return of the mapper function, and the second value being the chunk
///
/// @param arr array to be chunked
/// @param mapper mapping function designating the chunk "key"
/// @returns an iterable with pairs of chunk "keys" and chunks themselves.
Iterable<(K, List<T>)> chunkBy<T, K>(
  List<T> arr,
  K Function(T elem, int idx, List<T> arr) mapper,
) sync* {
  if (arr.isEmpty) {
    return;
  }

  K currentChunkValue = mapper(arr[0], 0, arr);
  late K newChunkValue;
  List<T> currentChunk = [arr[0]];

  for (int idx = 1; idx < arr.length; ++idx) {
    newChunkValue = mapper(arr[idx], idx, arr);
    if (currentChunkValue == newChunkValue) {
      // Still the same chunk, expand it
      currentChunk.add(arr[idx]);
      currentChunkValue = newChunkValue;
    } else {
      // Chunk boundary crossed, yield the current chunk and start the new one
      yield (currentChunkValue, currentChunk);
      currentChunkValue = newChunkValue;
      currentChunk = [arr[idx]];
    }
  }

  // Yield the last chunk we've been building up in the loop
  yield (currentChunkValue, currentChunk);
}
