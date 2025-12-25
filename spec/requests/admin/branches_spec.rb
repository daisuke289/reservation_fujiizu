require 'rails_helper'

RSpec.describe "Admin::Branches", type: :request do
  let(:branch) { create(:branch, default_capacity: 1) }

  # Basic認証のヘルパー
  def basic_auth
    username = ENV.fetch('BASIC_AUTH_USER', 'admin')
    password = ENV.fetch('BASIC_AUTH_PASSWORD', 'password')
    { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end

  describe "GET /admin/branches" do
    it "支店一覧が表示される" do
      get admin_branches_path, headers: basic_auth
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/branches/:id/edit" do
    it "支店編集画面が表示される" do
      get edit_admin_branch_path(branch), headers: basic_auth
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/branches/:id" do
    context "有効なパラメータの場合" do
      it "支店情報が更新される" do
        patch admin_branch_path(branch),
          params: { branch: { default_capacity: 3 } },
          headers: basic_auth

        expect(branch.reload.default_capacity).to eq(3)
        expect(response).to redirect_to(admin_branches_path)
      end

      it "成功メッセージが表示される" do
        patch admin_branch_path(branch),
          params: { branch: { default_capacity: 3 } },
          headers: basic_auth

        follow_redirect!
        expect(response.body).to include("情報を更新しました")
      end
    end

    context "無効なパラメータの場合" do
      it "更新に失敗する" do
        patch admin_branch_path(branch),
          params: { branch: { default_capacity: 0 } },
          headers: basic_auth

        expect(branch.reload.default_capacity).to eq(1)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "エラーメッセージが表示される" do
        patch admin_branch_path(branch),
          params: { branch: { default_capacity: 0 } },
          headers: basic_auth

        expect(response.body).to include("エラーが発生しました")
      end
    end
  end
end
