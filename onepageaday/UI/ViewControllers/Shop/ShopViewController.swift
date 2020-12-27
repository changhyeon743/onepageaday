//
//  ShopViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import UIKit
import FirebaseAuth
import SkeletonView

class ShopViewController: UIViewController, SkeletonTableViewDelegate, SkeletonTableViewDataSource {
    
    
    weak var parentDelegate: BookSelectingViewControllerDelegate?
    
    @IBOutlet var tableView: UITableView!
    var shopItems:[ShopItem]?
        /**/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopitemsUpdate()
        

        let nibName = UINib(nibName: "ShopCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func shopitemsUpdate() {
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.shopItems = [ShopItem(title: "남자에게 물어볼 50 가지 질문",
            detail: "https://psycatgames.com/ko/magazine/conversation-starters/250-questions-to-ask-a-guy/#5",
            questions: ["기술이 발전하면 \n 가능하다면 태어나려고합니까?",
               "할아버지의 헤어 스타일이나 이름을 원하십니까?",
               "가장 좋아하는 계절은 무엇이며 왜 그렇습니까?",
               "종교가 항상 존재할 것이라고 생각합니까?",
               "인공 지능에 대해 어떻게 생각하십니까?",
               "겨울에 스키를 타거나 여름에 해변에 갈래?",
               "하루 동안 소녀 였다면 가장 먼저 할 일은 무엇입니까?",
               "설명 할 수없는 경험을 해본 적이 있습니까?",
               "당신은 오히려 그랜드 캐년으로 낙하산으로 상어에 감염된 바다에서", "서핑을하거나 자유 낙하를 원하십니까?",
               "아무 이유없이 당신을 괴롭히는 사람들을 어떻게 대합니까?",
               "혼자서 외국 여행을 하시겠습니까?",
               "말 꼬리 나 유니콘 뿔을 원하십니까?",
               "어린 시절에 대해 무엇을 그리워합니까?",
               "자녀에게 가장 좋아하는 이름은 무엇입니까?",
               "사람들이 당신에게 묻지 않기를 바라는 것은 무엇입니까?",
               "냄새 나 맛을 잃어 버리겠습니까?",
               "학교에서 가장 좋아하는 과목은 무엇입니까?",
               "뱀을 잡거나 해파리와 키스 하시겠습니까?",
               "가장 비싼 것은 무엇입니까?",
               "지금까지 들었던 가장 이상한 대화는 무엇입니까?",
               "무엇을 알아 내기에는 너무 오래 걸렸습니까?",
               "누군가가 당신에게 한 최악의 조언은 무엇입니까?",
               "항상 좋아하는 노래를 머리에 영원히 꽂거나 밤에 항상 같은 것을", "꿈꾸겠습니까?",
               "집에 불이 붙었다면 무엇을 잡으시겠습니까?",
               "당신의 정반대는 어떻습니까?",
               "계란을 위해 닭고기를, 고기를 위해 쇠고기를 키우겠습니까?",
               "역사상 가장 큰 실수는 무엇입니까?",
               "당신의 성격을 가장 잘 나타내는 술은 무엇입니까?",
               "당신은 항상 어디에서나 건너 뛰거나 어디에서나 달려야합니까?",
               "당신의 이름은 무엇을 의미합니까?",
               "남자가 당신의 전화 번호를 요청하면 어떻게 하시겠습니까?",
               "돼지 코나 원숭이 얼굴을 원하십니까?",
               "재택 아빠가되고 싶습니까?",
               "우정의 가장 중요한 부분은 무엇입니까?",
               "손 대신 발이나 발 대신 손을 갖기를 원하십니까?",
               "매일 어떤 음식을 먹을 수 있습니까?",
               "어린 시절 가장 좋아하는 장난감은 무엇입니까?",
               "닉네임이 있습니까? 그렇게한다면 어떻게 얻었습니까?",
               "마지막으로 울었던 시간은 언제였으며 왜 그랬습니까?",
               "당신이받은 가장 이상한 선물은 무엇입니까?",
               "첫 번째 기억은 무엇입니까?",
               "당신의 인생에서 가장 행복한 순간은 무엇입니까?",
               "자녀에게 이상적인 이름은 무엇입니까?",
               "항상 썩은 고기 냄새를 맡거나 항상 스 unk 크 냄새를 맡으시겠습니까?",
               "아직도 어떤 유치한 것을 즐기십니까?",
               "어떤 음식을 먹지 않겠습니까?",
               "커피는 어떻습니까?",
               "당신은 오히려 하우스 보트 나 산의 오두막에서 살기를 원하십니까?",
               "가장 흥미로운 사실은 무엇입니까?",
               "휴식하는 사자와 함께 10 분 동안 앉아 있거나 배고픈 악어의 등을 가로 질러 달리고 싶습니까?"],
            imageLink: "https://psycatgames.com/ko/magazine/conversation-starters/250-questions-to-ask-a-guy/feature-image_hu4a7c8397bd008fb23013e84fd92f05ba_1338079_1920x1080_fill_q75_box_center.jpg", bookImage: "https://psycatgames.com/ko/magazine/conversation-starters/250-questions-to-ask-a-guy/feature-image_hu4a7c8397bd008fb23013e84fd92f05ba_1338079_1920x1080_fill_q75_box_center.jpg"),

            ShopItem(title: "여자에게 물어볼 50 가지 질문", detail: "질문", questions: [
                "전통적으로 여성스러운 것으로 간주되지 않는 것은 무엇입니까?",
                "가장 좋아하는 가상의 인물은 누구이며 왜 그런가요?",
                "당신은 오히려 모든 언어를 알고 동물과 대화하는 방법을 알고 싶습니까?",
                "은퇴 할 때 어디에서 살고 있는가?",
                "기침 할 때마다 웃거나 재채기를 할 때마다 딸꾹질을 하시겠습니까?",
                "커피는 어떻습니까?",
                "완벽한 고정 부리 토를 만드는 고정 조합은 무엇입니까?",
                "당신이 죽기 전에 성취하고 싶은 3 가지가 무엇입니까?",
                "누군가가 당신에게 말한 가장 큰 거짓말은 무엇입니까?",
                "모든 소리를 녹음 할 수있는 비디오 나 귀의 모든 것을 포착 할 수있는 눈을 원하십니까?",
                "스트레스를받을 때 당신을 완전히 이완시키는 것은 무엇입니까?",
                "마지막 Instagram 게시물의 실제 이야기는 무엇입니까?",
                "몇 살 때 커피를 즐기기 시작 했습니까?",
                "나이 많은 남자가 섹시하다고 생각하십니까?",
                "손톱을자를 때마다 손톱을 너무 짧게 자르거나 애완 동물을 소유 할 수 없습니까?",
                "당신이 어렸을 때 어른이 된 것에 대해 가장 좋은 것은 무엇입니까?",
                "음식을 먹을 때마다 페이지를 넘기거나 혀를 물 때마다 손가락으로 종이를 자르시겠습니까?",
                "몇 대의 휴대폰이 고장 났습니까?",
                "어떤 여성 유명인이 가장 큰 역할 모델입니까?",
                "콘돔 사용을 거부하는 남성에 대한 귀하의 의견은 무엇입니까?",
                "닉네임이 있습니까? 어떻게 얻었습니까?",
                "마지막으로 웃었던 시간이 언제였습니까?",
                "세상에서 가장 강한 사람입니까 아니면 세상에서 가장 빠른 사람입니까?",
                "당신은 너무 나이가 많지만 여전히 즐기십니까?",
                "당신이 정말로 강조한 것은 무엇입니까?",
                "공유하고 싶은 나쁜 이야기 나 재미있는 이야기가 있습니까?",
                "가장 좋아하는 휴일은 무엇입니까?",
                "어떤 책을 두 번 이상 읽었습니까?",
                "지난 몇 년 동안 어떻게 변했다고 생각하십니까?",
                "사람들이 당신을 볼 때 자동으로 당신에 대해 어떻게 생각하십니까?",
                "감정적 친밀감에 대한 당신의 정의는 무엇입니까?",
                "여자와 키스 한 적이 있습니까?",
                "성공한 사람들이 좋아하는 인용문이 있습니까?",
                "전기의 이름을 어떻게 지정 하시겠습니까?",
                "어떤 게임이나 영화 세계에서 가장 살고 싶은가?",
                "귀하의 언어를 가장 잘 듣는 악센트는 무엇입니까?",
                "첫 해외 여행은 무엇입니까? 당신은 그것을 좋아 했습니까?",
                "어떤 영화를 7 번 이상 본 적이 있습니까?",
                "어떤 유형의 사람들이 마음에 들지 않습니까?",
                "당신의 완벽한 버거는 무엇입니까?",
                "재능으로 유명한 사람은 누구입니까?",
                "대머리가 섹시하다고 생각하십니까?",
                "당신이 누군가에게 진실하다고 확신 한 가장 우스운 것은 무엇입니까?",
                "자라면서 애완 동물이 있습니까?",
                "당신이 싫어하는 5 가지를 말하고 이유를 말해주세요.",
                "긴장하거나 긴장할 때 몸 전체가 파랗게 변하겠습니까?",
                "당신에게 가장 아름다운 단어는 무엇입니까?",
                "가장 좋은 결정은 무엇입니까?",
                "처녀가되는 것이 어색하다고 생각되는 나이가 있습니까?",
                "할머니가 당신에게 준 가장 좋은 조언은 무엇입니까?",
            ], imageLink: <#T##String#>, bookImage: <#T##String#>)
            ]
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ShopCell"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopItems?.count ?? 10
        
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopItems?.count ?? 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //https://psycatgames.com/ko/magazine/conversation-starters/250-questions-to-ask-a-guy/#5
        if shopItems != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShopCell
            cell.hideSkeleton()
            
            cell.titleLabel.text = shopItems![indexPath.row].title
            cell.detailLabel.text = shopItems![indexPath.row].detail
            
            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.addTarget(self, action: #selector(downloadButtonPressed(_:)), for: .touchUpInside)
            cell.itemImageView?.kf.indicatorType = .activity
            cell.itemImageView?.kf.setImage(with: URL(string:shopItems![indexPath.row].imageLink))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShopCell
            cell.showAnimatedGradientSkeleton()
            cell.titleLabel.showAnimatedGradientSkeleton()
            cell.detailLabel.showAnimatedGradientSkeleton()
            cell.itemImageView.showAnimatedGradientSkeleton()
            cell.downloadButton.showAnimatedGradientSkeleton()
            return cell
        }
    }
    
    @objc func downloadButtonPressed(_ sender:UIButton) {
        let row = sender.tag
        if (shopItems == nil) { return }
        let book = Book(title: shopItems![row].title,
                        detail: shopItems![row].detail,
                        author: Auth.auth().currentUser?.uid ?? "",
                        currentIndex: 0,
                        backGroundImage: shopItems![row].bookImage,
                        createDate: Date(),
                        modifiedDate: Date())
        
        API.firebase.addBook(book: book, question: shopItems![row].questions) {
            let alert = UIAlertController(title: "다운로드 완료", message: "\(book.title)이(가) 서랍에 추가됨", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.parentDelegate?.bookDownloaded()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "ShopDetailViewController") as? ShopDetailViewController {
            vc.title = shopItems?[indexPath.row].title
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}
