const { chromium } = require('playwright');

(async () => {
  console.log('=== 予約フロー E2Eテスト開始 ===\n');

  const browser = await chromium.launch({ headless: false, slowMo: 500 });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    // セッションを維持するためにCookieを有効化
    acceptDownloads: false,
    ignoreHTTPSErrors: false
  });
  const page = await context.newPage();

  let issues = [];
  let currentStep = '';

  try {
    // ステップ1: ホームページアクセス
    currentStep = 'ホームページアクセス';
    console.log(`[ステップ1] ${currentStep}`);
    await page.goto('http://localhost:3000');
    await page.screenshot({ path: 'screenshots/01_home.png' });

    const title = await page.textContent('h1');
    if (!title.includes('相続相談')) {
      issues.push(`${currentStep}: タイトルに「相続相談」が見つかりません`);
    }
    console.log('✓ ホームページ表示成功');

    // ステップ2: 予約開始
    currentStep = '予約開始ボタンクリック';
    console.log(`\n[ステップ2] ${currentStep}`);
    const reserveButton = page.locator('a:has-text("今すぐ予約する")');
    if (await reserveButton.count() === 0) {
      issues.push(`${currentStep}: 予約開始ボタンが見つかりません`);
      throw new Error('予約開始ボタンが見つかりません');
    }
    await reserveButton.click();
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'screenshots/02_area_selection.png' });
    console.log('✓ エリア選択ページへ遷移成功');

    // ステップ3: エリア選択
    currentStep = 'エリア選択（富士地区）';
    console.log(`\n[ステップ3] ${currentStep}`);
    // button_toで生成されたフォームのボタンを探す
    const areaButton = page.locator('button:has(h3:has-text("富士地区"))').first();
    if (await areaButton.count() === 0) {
      issues.push(`${currentStep}: 富士地区が見つかりません`);
      throw new Error('富士地区が見つかりません');
    }
    await areaButton.click();
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'screenshots/03_branch_selection.png' });
    console.log('✓ 支店選択ページへ遷移成功');

    // ステップ4: 支店選択
    currentStep = '支店選択（富士支店）';
    console.log(`\n[ステップ4] ${currentStep}`);
    // 富士支店が表示されているか確認
    const branchHeading = await page.locator('h3:has-text("富士支店")').first();
    if (await branchHeading.count() === 0) {
      issues.push(`${currentStep}: 富士支店が見つかりません`);
      throw new Error('富士支店が見つかりません');
    }
    // 「この支店で予約する」ボタンを最初のものをクリック（富士地区の最初の富士支店）
    const branchButton = page.locator('a:has-text("この支店で予約する")').first();
    await branchButton.click();
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'screenshots/04_calendar.png' });
    console.log('✓ カレンダーページへ遷移成功');

    // ステップ5: 日付選択（予約可能な日付をクリック）
    currentStep = 'カレンダーで日付選択';
    console.log(`\n[ステップ5] ${currentStep}`);
    // グリーンの背景を持つ予約可能な日付リンクを探す
    const availableDate = page.locator('a.from-green-100').first();
    if (await availableDate.count() === 0) {
      issues.push(`${currentStep}: 予約可能な日付が見つかりません`);
      throw new Error('予約可能な日付が見つかりません');
    }
    await availableDate.click();
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'screenshots/05_time_selection.png' });
    console.log('✓ 時間選択ページへ遷移成功');

    // ステップ6: 時間選択
    currentStep = '時間スロット選択';
    console.log(`\n[ステップ6] ${currentStep}`);
    // border-gray-300を持つ時間スロットリンクを探す
    const timeSlot = page.locator('a.border-gray-300').first();
    if (await timeSlot.count() === 0) {
      issues.push(`${currentStep}: 利用可能な時間スロットが見つかりません`);
      throw new Error('利用可能な時間スロットが見つかりません');
    }
    await timeSlot.click();
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'screenshots/06_customer_form.png' });
    console.log('✓ 顧客情報入力ページへ遷移成功');

    // ステップ7: 顧客情報入力
    currentStep = '顧客情報入力';
    console.log(`\n[ステップ7] ${currentStep}`);
    await page.fill('input[name="appointment[name]"]', '山田太郎');
    await page.fill('input[name="appointment[furigana]"]', 'ヤマダタロウ');
    await page.fill('input[name="appointment[phone]"]', '09012345678');
    await page.fill('input[name="appointment[email]"]', 'test@example.com');
    await page.selectOption('select[name="appointment[appointment_type_id]"]', { index: 1 });
    await page.selectOption('select[name="appointment[party_size]"]', '1');
    await page.check('input[type="checkbox"][name="appointment[accept_privacy]"]');
    await page.screenshot({ path: 'screenshots/07_customer_form_filled.png' });
    console.log('✓ 顧客情報入力完了');

    // ステップ8: 確認画面へ
    currentStep = '確認画面へ遷移';
    console.log(`\n[ステップ8] ${currentStep}`);
    const confirmButton = page.locator('button:has-text("入力内容を確認する")');
    if (await confirmButton.count() === 0) {
      issues.push(`${currentStep}: 確認ボタンが見つかりません`);
      throw new Error('確認ボタンが見つかりません');
    }
    await confirmButton.click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000); // セッション維持のため追加待機
    await page.screenshot({ path: 'screenshots/08_confirm.png' });

    // デバッグ: ページのURLとタイトルを確認
    const currentUrl = page.url();
    const currentTitle = await page.title();
    console.log(`  現在のURL: ${currentUrl}`);
    console.log(`  ページタイトル: ${currentTitle}`);

    // デバッグ: ページ内のボタンを全て表示
    const buttons = await page.locator('button').allTextContents();
    console.log(`  見つかったボタン: ${JSON.stringify(buttons)}`);

    if (currentUrl.includes('reserve_steps_area')) {
      issues.push(`${currentStep}: セッションが切れてエリア選択に戻されました`);
      throw new Error('セッションエラー: エリア選択に戻されました');
    }

    console.log('✓ 確認画面へ遷移成功');

    // ステップ9: 予約確定
    currentStep = '予約確定';
    console.log(`\n[ステップ9] ${currentStep}`);
    const submitButton = page.locator('button:has-text("予約を確定する")');
    if (await submitButton.count() === 0) {
      issues.push(`${currentStep}: 予約確定ボタンが見つかりません`);
      throw new Error('予約確定ボタンが見つかりません');
    }
    await submitButton.click();
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'screenshots/09_complete.png' });
    console.log('✓ 予約完了画面へ遷移成功');

    // ステップ10: 完了画面確認
    currentStep = '完了画面確認';
    console.log(`\n[ステップ10] ${currentStep}`);
    const completeMessage = await page.textContent('body');
    if (!completeMessage.includes('予約が完了しました') && !completeMessage.includes('ご予約ありがとうございます')) {
      issues.push(`${currentStep}: 完了メッセージが見つかりません`);
    }
    console.log('✓ 予約完了メッセージ確認成功');

    console.log('\n=== テスト完了 ===');
    if (issues.length === 0) {
      console.log('✅ 全てのステップが正常に動作しました！');
    } else {
      console.log('⚠️  以下の問題が見つかりました：');
      issues.forEach((issue, index) => {
        console.log(`  ${index + 1}. ${issue}`);
      });
    }

  } catch (error) {
    console.error(`\n❌ エラー発生: ${currentStep}`);
    console.error(`詳細: ${error.message}`);
    await page.screenshot({ path: `screenshots/error_${Date.now()}.png` });
    issues.push(`${currentStep}: ${error.message}`);
  } finally {
    await browser.close();

    // 結果サマリー
    console.log('\n=== テスト結果サマリー ===');
    console.log(`検出された問題数: ${issues.length}`);
    if (issues.length > 0) {
      console.log('\n問題詳細:');
      issues.forEach((issue, index) => {
        console.log(`  ${index + 1}. ${issue}`);
      });
    }

    process.exit(issues.length > 0 ? 1 : 0);
  }
})();
