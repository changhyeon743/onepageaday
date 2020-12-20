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
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.shopItems = [ShopItem(title: "남자에게 물어볼 50 가지 질문",
            detail: "https://psycatgames.com/ko/magazine/conversation-starters/250-questions-to-ask-a-guy/#5",
            questions: ["기술이 발전하면 가능하다면 태어나려고합니까?",
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
            imageLink: "https://psycatgames.com/ko/magazine/conversation-starters/250-questions-to-ask-a-guy/feature-image_hu4a7c8397bd008fb23013e84fd92f05ba_1338079_1920x1080_fill_q75_box_center.jpg"),

       ShopItem(title: "남자에게 물어볼 첫 데이트 질문 50 개",
                detail: "데이트",
                questions: ["당신이 방문한 가장 흥미로운 도시는 무엇입니까?",
                            "소녀를 위해 해 본 가장 달콤한 일은 무엇입니까?",
                            "여성에 대해 가장 먼저 눈에 띄는 것은 무엇입니까?",
                            "당신의 마음이 상한 적이 있습니까?",
                            "데이트를 시작할 때 몇 살 이었습니까?",
                            "당신의 꿈의 여자는 누구입니까?",
                            "당신이 생각하는 것보다 더 작은 것이 당신을 더 화나게합니까?",
                            "당신의 완벽한 파트너가 당신을 어떻게 대할 것입니까?",
                            "마지막으로 갔던 콘서트는 무엇입니까?",
                            "사랑이 평생 지속될 수 있다고 생각하십니까?",
                            "당신이 데이트하기 전에 소녀가 알고 싶은 것들이 무엇입니까?",
                            "어떤 소셜 미디어를 가장 자주 사용하십니까?",
                            "당신의 삶을 더 좋게 만들기 위해 사람들이 이타 적으로 행한 일은 무엇입니까?",
                            "여성에게 매력적인 점이 무엇입니까?",
                            "독신 생활에 대한 가장 좋은 점은 무엇입니까?",
                            "영구적으로 몇 살이 되길 원하십니까?",
                            "무엇이 좋은 삶을 만드는가?",
                            "자랑스럽게 생각하는 것이 무엇입니까?",
                            "나이가 들면 배우자 전후에 죽을 것입니까?",
                            "여자와 자면서 가장 좋아하는 것은 무엇입니까?",
                            "어디를 여행 했습니까?",
                            "당신은 오히려 나쁜 성격을 가진 10 명이나 놀라운 성격을 가진 6 명과 결혼하고 싶습니까?",
                            "요리사 나 하녀를 원하십니까?",
                            "인생에서 어떤 전환점이 있었습니까?",
                            "당신은 여전히 exes와 친구입니까?",
                            "전기의 이름을 어떻게 지정 하시겠습니까?",
                            "무엇이 특별하고 독특합니까?",
                            "어렸을 때 무엇을 알고 싶었습니까?",
                            "처녀성을 어떻게 잃었습니까?",
                            "당신은 너무 바쁘거나 지루합니까?",
                            "맹인과 데이트를 해 본 적이 있습니까?",
                            "우리의 관계에 대해 어떻게 생각하십니까?",
                            "마지막 관계는 어떻게 끝났습니까?",
                            "미래에 대해 가장 두려워하는 것은 무엇입니까?",
                            "울었던 마지막 영화는 무엇입니까?",
                            "어린 시절 가장 좋아했던 게임은 무엇입니까?",
                            "체중 증가가 누군가와 헤어질 수있는 적절한 이유라고 생각하십니까?",
                            "여자는 남자와 동등합니까?",
                            "어떤 게임이나 영화 세계에서 가장 살고 싶으십니까?",
                            "가장 긴 낭만적 인 관계의 길이는 얼마입니까?",
                            "사랑이 무엇인지 어떻게 설명 하시겠습니까?",
                            "“실제 사람”에 대한 당신의 정의는 무엇입니까?",
                            "당신에게 일어난 가장 초자연적 인 일은 무엇입니까?",
                            "멋진 여자를 위해 침대에서 아침 식사를 하시겠습니까?",
                            "책을 쓰려고한다면 어떤 종류입니까?",
                            "내가 없을 때 나를 생각합니까?",
                            "시간을 거슬러 올라갈 수 있다면 자녀에게 무엇을 말 하시겠습니까?",
                            "당신이 끌리는 이성에 대해 한 가지는 무엇입니까?",
                            "집에 책이없는 사람과 데이트를 하시겠습니까?",
                            "열린 관계에 대한 당신의 감정은 무엇입니까?",
                ],
                imageLink: "https://lh3.googleusercontent.com/proxy/ki4Ax_AQ3MlimVMDrpkiuczPiBkn1lXrIEOPvm0OOerZsDrhL5KUeOF4E8PMeN_40bYfoPMpvY6G4v3z-fUBRHoLRu0IcTeFqDRbjQ-XookqrFCkHjy4Lzaw97lcUfVVrKd55ad5iUAoog5LiNrbasgzDwKnnwQdJoDlah-aSSnlck15ZpB7KxCOfloAkBhQla48dtIm-jHu28EtWutuqORsBkPTBUPtl1GJ4aDj2iYFKsESel42jUWf3YTGkqCBIh02ae2lq1aub7Z0B9OJiQZ_9_W0HUAvG6mICtiYODzEn2w")]
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
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "ShopDetailViewController") as? ShopDetailViewController {
            vc.title = shopItems?[indexPath.row].title
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}
