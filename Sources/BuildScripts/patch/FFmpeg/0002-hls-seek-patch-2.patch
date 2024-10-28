From 07045b8245cfc5822005c716db8a84b710579787 Mon Sep 17 00:00:00 2001
From: llyyr <llyyr.public@gmail.com>
Date: Sun, 27 Oct 2024 06:44:51 +0530
Subject: [PATCH 2/2] avformat/mov: handle stream position resets

If the stream position has been reset, clear fragment index, the index
entries and the current sample and search for the next root.

Co-Authored-by: vectronic <hello.vectronic@gmail.com>
---
 libavformat/mov.c | 37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

diff --git a/libavformat/mov.c b/libavformat/mov.c
index 8c3329b81596..78540bec1d11 100644
--- a/libavformat/mov.c
+++ b/libavformat/mov.c
@@ -10612,15 +10612,15 @@ static int mov_switch_root(AVFormatContext *s, int64_t target, int index)
 
     if (index >= 0 && index < mov->frag_index.nb_items)
         target = mov->frag_index.item[index].moof_offset;
-    if (avio_seek(s->pb, target, SEEK_SET) != target) {
+    if (target >= 0 && avio_seek(s->pb, target, SEEK_SET) != target) {
         av_log(mov->fc, AV_LOG_ERROR, "root atom offset 0x%"PRIx64": partial file\n", target);
         return AVERROR_INVALIDDATA;
     }
 
     mov->next_root_atom = 0;
-    if (index < 0 || index >= mov->frag_index.nb_items)
+    if ((index < 0 && target >= 0) || index >= mov->frag_index.nb_items)
         index = search_frag_moof_offset(&mov->frag_index, target);
-    if (index < mov->frag_index.nb_items &&
+    if (index >= 0 && index < mov->frag_index.nb_items &&
         mov->frag_index.item[index].moof_offset == target) {
         if (index + 1 < mov->frag_index.nb_items)
             mov->next_root_atom = mov->frag_index.item[index + 1].moof_offset;
@@ -10751,9 +10751,38 @@ static int mov_read_packet(AVFormatContext *s, AVPacket *pkt)
     AVIndexEntry *sample;
     AVStream *st = NULL;
     int64_t current_index;
-    int ret;
+    int ret, i;
     mov->fc = s;
  retry:
+    if (s->pb->pos == 0) {
+        // Discard current fragment index
+        if (mov->frag_index.allocated_size > 0) {
+            av_freep(&mov->frag_index.item);
+            mov->frag_index.nb_items = 0;
+            mov->frag_index.allocated_size = 0;
+            mov->frag_index.current = -1;
+            mov->frag_index.complete = 0;
+        }
+
+        for (i = 0; i < s->nb_streams; i++) {
+            AVStream *avst = s->streams[i];
+            FFStream *sti = ffstream(avst);
+            MOVStreamContext *msc = avst->priv_data;
+
+            // Clear current sample
+            mov_current_sample_set(msc, 0);
+
+            // Discard current index entries
+            if (sti->index_entries_allocated_size > 0) {
+                av_freep(&sti->index_entries);
+                sti->index_entries_allocated_size = 0;
+                sti->nb_index_entries = 0;
+            }
+        }
+
+        if ((ret = mov_switch_root(s, -1, -1)) < 0)
+            return ret;
+    }
     sample = mov_find_next_sample(s, &st);
     if (!sample || (mov->next_root_atom && sample->pos > mov->next_root_atom)) {
         if (!mov->next_root_atom)
-- 
2.47.0