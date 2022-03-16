import EctoEnum
defenum ContentStatusEnum, inactive: 0, active: 1, archived: 2, soft_delete: 3
defenum ContentPriorityEnum, none: 0, low: 1, medium: 2, high: 3, featured: 4
defenum ContentRobotsEnum, IndexFollow: 0, IndexNoFollow: 1, NoIndexFollow: 2, NoIndexNoFollow: 3
defenum CategoryVisibility, show: 0, invisibel: 1, test_show: 2, test_invisibel: 3
defenum PostVisibility, show: 0, invisibel: 1, test_show: 2, test_invisibel: 3
defenum CommentSection, blog_post: 0
defenum SubscriptionSection, blog_post: 0, blog_category: 1
defenum BlogLinkType, bottom: 0, inside: 1, featured: 2
defenum ActivitiesStatusEnum, error: 0, info: 1, warning: 2, report: 3, throw: 4, exit: 5
defenum ActivitiesTypeEnum, section: 0, email: 1, internal_api: 2, external_api: 3, html_router: 4, api_router: 5, db: 6, plugin: 7
defenum ActivitiesSection, blog_post: 0, blog_category: 1, comment: 2, tag: 3, other: 4, blog_author: 5, blog_post_like: 6, blog_tag_mapper: 7, blog_link: 8, blog_tag: 9, activity: 10, bookmark: 11, comment_like: 12, notif: 13, subscription: 14, setting: 15, permission: 16, role: 17, user_role: 18, identity: 19, user: 20
defenum ActivitiesAction, add: 0, edit: 1, delete: 2, destroy: 3, read: 4, send_request: 5, receive_request: 6, other: 7, auth: 8
defenum BookmarkSection, blog_post: 0
defenum NotifSection, blog_post: 0, admin: 1, user_only: 3, public: 4
defenum NotifStatusType, read: 0, skipped: 1
defenum NotifType, client: 0, admin: 1
defenum NotifTarget, all: 0, mobile: 1, android: 2, ios: 3, cli: 4
