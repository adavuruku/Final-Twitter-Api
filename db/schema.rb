# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_02_202924) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "followers", force: :cascade do |t|
    t.string "userid", null: false
    t.string "followerid", null: false
    t.bigint "users_record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["id", "users_record_id"], name: "followers_list_index"
    t.index ["users_record_id"], name: "index_followers_on_users_record_id"
  end

  create_table "followings", force: :cascade do |t|
    t.string "userid", null: false
    t.string "followingid", null: false
    t.bigint "users_record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["id", "users_record_id"], name: "following_list_index"
    t.index ["users_record_id"], name: "index_followings_on_users_record_id"
  end

  create_table "tweets", force: :cascade do |t|
    t.text "tweetinfo", null: false
    t.string "userid", null: false
    t.bigint "users_record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "likes", default: [], array: true
    t.index ["id", "users_record_id", "tweetinfo"], name: "tweets_list_index"
    t.index ["users_record_id"], name: "index_tweets_on_users_record_id"
  end

  create_table "users_records", force: :cascade do |t|
    t.string "userfullname", null: false
    t.string "userid", null: false
    t.string "username", null: false
    t.string "useremail", null: false
    t.string "userphone"
    t.string "userbio"
    t.string "userlocation"
    t.string "userwebsite"
    t.text "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "dob"
    t.index ["userid", "username", "useremail"], name: "userd_record_list_index", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "followers", "users_records"
  add_foreign_key "followings", "users_records"
  add_foreign_key "tweets", "users_records"
end
